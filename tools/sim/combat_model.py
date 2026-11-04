"""Simplified single-exchange / ladder combat for offline balance Monte Carlo."""

from __future__ import annotations

import random
from dataclasses import dataclass, field
from typing import Any, Optional


@dataclass
class ItemInst:
    id: str
    name: str
    kind: Optional[str]
    ops: dict
    supported: bool
    spent: bool = False
    # Mutable card state
    sai_val: int = 2
    shield_is_atk: bool = True
    lantern_n: int = 1
    keep_flag: bool = False


@dataclass
class FightState:
    player_hp: int
    player_hp_max: int
    blk: int = 0
    hp_loss_events: int = 0  # dungeon-scoped (Flail)
    lost_hp_this_combat: bool = False
    mobs_defeated: int = 0
    items: list[ItemInst] = field(default_factory=list)
    # Fight-local
    enemy_hp: int = 0
    enemy_atk: int = 0
    enemy_id: str = ""
    enemy_special: Optional[str] = None
    enemy_alive: bool = True
    atk_drop: int = 0  # Net residual this fight
    turns: int = 0  # items used + resolve steps
    items_used: int = 0
    escaped: bool = False
    dead: bool = False
    won: bool = False
    log: list[str] = field(default_factory=list)

    def live_items(self) -> list[ItemInst]:
        return [it for it in self.items if not it.spent]

    def has_potion(self) -> bool:
        return any(it.id == "healing_potion" and not it.spent for it in self.items)

    def consume_potion(self) -> bool:
        for it in self.items:
            if it.id == "healing_potion" and not it.spent:
                it.spent = True
                before = self.player_hp
                self.player_hp = min(self.player_hp_max, max(0, self.player_hp) + 3)
                if self.player_hp <= 0:
                    self.player_hp = min(3, self.player_hp_max)
                self.log.append(f"potion: {before}-> {self.player_hp}")
                return True
        return False

    def note_hp_loss(self, lost: int) -> None:
        if lost <= 0:
            return
        self.hp_loss_events += 1
        self.lost_hp_this_combat = True


def make_item(spec: dict) -> ItemInst:
    ops = dict(spec.get("ops") or {})
    kind = spec.get("kind") or ops.get("kind")
    return ItemInst(
        id=spec["id"],
        name=spec.get("name") or spec["id"],
        kind=kind,
        ops=ops,
        supported=bool(spec.get("supported")),
    )


def incoming_damage(state: FightState, atk: Optional[int] = None, pierce: bool = False) -> tuple[int, int]:
    """Return (hp_lost, blk_after)."""
    swing = state.enemy_atk if atk is None else atk
    swing = max(0, swing - state.atk_drop)
    if pierce or state.enemy_special == "pierce":
        return swing, state.blk
    dmg = max(0, swing - state.blk)
    blk_left = max(0, state.blk - swing)
    return dmg, blk_left


def apply_swing(state: FightState, atk: Optional[int] = None, pierce: bool = False) -> int:
    dmg, blk_left = incoming_damage(state, atk=atk, pierce=pierce)
    if not (pierce or state.enemy_special == "pierce"):
        state.blk = blk_left
    before = state.player_hp
    state.player_hp = max(0, state.player_hp - dmg)
    lost = before - state.player_hp
    state.note_hp_loss(lost)
    state.log.append(f"swing dmg={dmg} hp={state.player_hp} blk={state.blk}")
    if state.player_hp <= 0:
        if state.consume_potion():
            state.dead = False
        else:
            state.dead = True
    return lost


def defeat_enemy(state: FightState) -> None:
    state.enemy_alive = False
    state.enemy_hp = 0
    state.won = True
    state.mobs_defeated += 1
    state.log.append(f"defeat {state.enemy_id}")


def deal_atk(state: FightState, n: int) -> None:
    if n <= 0 or not state.enemy_alive:
        return
    if state.enemy_special == "no_atk_dmg":
        state.log.append(f"atk {n} ignored (goblin)")
        return
    state.enemy_hp = max(0, state.enemy_hp - n)
    state.log.append(f"atk {n} -> enemy_hp={state.enemy_hp}")
    if state.enemy_hp <= 0:
        defeat_enemy(state)


def discard_or_keep(state: FightState, it: ItemInst, keep: bool) -> None:
    if keep:
        it.spent = False
        it.keep_flag = True
        state.log.append(f"keep {it.id}")
    else:
        it.spent = True


def flail_atk(state: FightState) -> int:
    return 2 * state.hp_loss_events


def can_use(state: FightState, it: ItemInst) -> bool:
    if it.spent or not it.supported or not it.kind:
        return False
    if not state.enemy_alive and it.kind not in ("heal", "heal_keep", "passive"):
        return False
    kind = it.kind
    if kind == "defeat_hp":
        return state.enemy_alive and state.enemy_hp < state.player_hp
    if kind == "defeat_atk":
        return state.enemy_alive and (state.enemy_atk - state.atk_drop) >= 6
    if kind == "fangs":
        return state.enemy_alive
    if kind == "passive":
        return False  # unplayable
    if kind == "atk_opposite":
        return False  # needs across seat
    if kind == "blk_neighbor":
        return False  # needs neighbor
    if kind == "atk_hp_loss":
        return state.enemy_alive and flail_atk(state) > 0
    if kind == "atk_last":
        return False  # no last-mob memory in duel unless ladder sets it
    return True


def use_item(state: FightState, it: ItemInst, rng: random.Random, choice: Optional[str] = None) -> None:
    """Apply one item. Harpy after-item swing handled by caller."""
    if not can_use(state, it):
        return
    kind = it.kind
    ops = it.ops
    state.items_used += 1
    state.turns += 1
    state.log.append(f"use {it.id} ({kind})")

    if kind == "blk":
        n = int(ops.get("n", 0))
        state.blk += n
        if it.id == "rust":
            before = state.player_hp
            state.player_hp = max(0, state.player_hp - 1)
            state.note_hp_loss(before - state.player_hp)
            if state.player_hp <= 0 and not state.consume_potion():
                state.dead = True
        discard_or_keep(state, it, False)
        return

    if kind == "atk":
        deal_atk(state, int(ops.get("n", 0)))
        if it.id == "arrow_head":
            before = state.player_hp
            state.player_hp = max(0, state.player_hp - 2)
            state.note_hp_loss(before - state.player_hp)
            if state.player_hp <= 0 and not state.consume_potion():
                state.dead = True
        discard_or_keep(state, it, False)
        return

    if kind == "choose":
        # Throwing knife or Net
        options = ops.get("options") or []
        if it.id == "throwing_knife" or any("atk" in o for o in options):
            if choice == "nick" or (choice is None and state.enemy_hp <= 1):
                deal_atk(state, 1)
                discard_or_keep(state, it, True)
            else:
                # prefer throw (3) when it kills or by default
                deal_atk(state, 3)
                discard_or_keep(state, it, False)
        else:
            # Net: drop atk
            drop = 3
            if choice == "drop1":
                drop = 1
            elif choice == "drop2":
                drop = 2
            state.atk_drop += drop
            discard_or_keep(state, it, False)
        return

    if kind == "defeat_hp":
        if state.enemy_hp < state.player_hp:
            discard_or_keep(state, it, False)
            defeat_enemy(state)
        return

    if kind == "defeat_atk":
        if (state.enemy_atk - state.atk_drop) >= 6:
            discard_or_keep(state, it, False)
            defeat_enemy(state)
        return

    if kind == "fangs":
        stored = state.enemy_hp
        apply_swing(state)
        if state.dead:
            discard_or_keep(state, it, False)
            return
        discard_or_keep(state, it, False)
        defeat_enemy(state)
        before = state.player_hp
        state.player_hp = min(state.player_hp_max, state.player_hp + stored)
        state.log.append(f"fangs heal {before}->{state.player_hp}")
        return

    if kind == "atk_hp_loss":
        deal_atk(state, flail_atk(state))
        discard_or_keep(state, it, False)
        return

    if kind == "blk_keep":
        n = int(ops.get("n", 2))
        state.blk += n
        # Keep decided at end of combat if bled
        it._pending_keep = True  # type: ignore[attr-defined]
        discard_or_keep(state, it, False)
        it.spent = True
        return

    if kind == "heal_keep":
        n = int(getattr(it, "lantern_n", ops.get("n", 1)) or 1)
        before = state.player_hp
        state.player_hp = min(state.player_hp_max, state.player_hp + n)
        it.lantern_n = n + 1
        keep = state.player_hp < state.player_hp_max
        discard_or_keep(state, it, keep)
        if keep:
            it.spent = False
        state.log.append(f"lantern heal {before}->{state.player_hp} keep={keep}")
        return

    if kind == "heal":
        n = int(ops.get("n", 2))
        state.player_hp = min(state.player_hp_max, state.player_hp + n)
        discard_or_keep(state, it, False)
        return

    if kind == "heal_kills":
        n = 1 + state.mobs_defeated
        state.player_hp = min(state.player_hp_max, state.player_hp + n)
        discard_or_keep(state, it, False)
        return

    if kind == "atk_7_hp":
        deal_atk(state, 1 + max(0, state.player_hp_max - state.player_hp))
        discard_or_keep(state, it, False)
        return

    if kind == "blk_from_hp":
        state.blk += max(0, state.player_hp_max - state.player_hp)
        discard_or_keep(state, it, False)
        return

    if kind == "blk_min_hp":
        state.blk += min(state.player_hp, state.enemy_hp)
        discard_or_keep(state, it, False)
        return

    if kind == "atk_alt_24":
        deal_atk(state, it.sai_val)
        it.sai_val = 4 if it.sai_val == 2 else 2
        discard_or_keep(state, it, False)
        return

    if kind == "shield_alt":
        if it.shield_is_atk:
            deal_atk(state, 3)
        else:
            state.blk += 3
        it.shield_is_atk = not it.shield_is_atk
        discard_or_keep(state, it, False)
        return

    if kind in ("atk_neighbor", "atk_cleave"):
        n = int(ops.get("n", 2 if kind == "atk_cleave" else 4))
        deal_atk(state, n)
        discard_or_keep(state, it, False)
        return

    if kind == "flee_then_blk":
        # Simplified: gain block, mark escaped if we then Done without killing
        state.blk += int(ops.get("n", 5))
        discard_or_keep(state, it, False)
        return

    if kind == "smoke":
        discard_or_keep(state, it, False)
        state.escaped = True
        state.enemy_alive = False
        state.won = False
        state.log.append("smoke escape")
        return

    # Fallback: mark spent
    discard_or_keep(state, it, False)


def resolve_breastplate_keeps(state: FightState) -> None:
    for it in state.items:
        if it.id == "breastplate" and getattr(it, "_pending_keep", False):
            if state.lost_hp_this_combat:
                it.spent = False
                it.keep_flag = True
            it._pending_keep = False  # type: ignore[attr-defined]


def harpy_item_swing(state: FightState) -> None:
    if state.enemy_special == "impatient" and state.enemy_alive and not state.dead:
        apply_swing(state)


def shark_attack(state: FightState) -> None:
    """Shark: swing until HP lost this attack sequence, or 5 zero-dmg swings."""
    zeros = 0
    while state.enemy_alive and not state.dead and zeros < 5:
        lost = apply_swing(state)
        if lost > 0:
            break
        zeros += 1


def resolve_done(state: FightState) -> None:
    state.turns += 1
    if not state.enemy_alive or state.dead or state.escaped:
        resolve_breastplate_keeps(state)
        return
    special = state.enemy_special
    if special == "blood_thresh":
        shark_attack(state)
    elif special == "double_hit":
        apply_swing(state)
        if not state.dead and state.enemy_alive:
            apply_swing(state)
    else:
        apply_swing(state)
    # Survive hit => monster still removed (one_encounter_then_gone)
    if not state.dead and state.enemy_alive:
        defeat_enemy(state)
        state.log.append("survived hit; slice removed")
    resolve_breastplate_keeps(state)


def start_fight(state: FightState, monster: dict) -> None:
    state.blk = 0
    state.lost_hp_this_combat = False
    state.atk_drop = 0
    state.escaped = False
    state.won = False
    state.enemy_id = monster["id"]
    state.enemy_hp = int(monster["hp"])
    state.enemy_atk = int(monster["atk"])
    state.enemy_special = monster.get("special")
    state.enemy_alive = True
    state.dead = False

    # Simplified specials at fight start
    if state.enemy_special == "kill_shot":
        state.enemy_atk = state.player_hp
    elif state.enemy_special == "hoarder":
        state.enemy_atk = len(state.live_items())
    elif state.enemy_special == "atk_eq_hp":
        state.enemy_atk = state.enemy_hp

    # Harpy on-spin swing
    if state.enemy_special == "impatient":
        apply_swing(state)


def expected_incoming(state: FightState) -> int:
    pierce = state.enemy_special == "pierce"
    dmg, _ = incoming_damage(state, pierce=pierce)
    if state.enemy_special == "double_hit":
        # rough: two swings with blk spent on first
        first, blk_left = incoming_damage(state, pierce=pierce)
        tmp_blk = state.blk
        state.blk = blk_left
        second, _ = incoming_damage(state, pierce=pierce)
        state.blk = tmp_blk
        return first + second
    if state.enemy_special == "blood_thresh":
        # worst case: enough swings to chip through block then 1 dmg
        return max(1, dmg) if dmg > 0 else 1
    return dmg


def greedy_survive_policy(state: FightState, rng: random.Random) -> Optional[ItemInst]:
    """Pick next item or None for Done."""
    if state.dead or not state.enemy_alive or state.escaped:
        return None
    live = [it for it in state.live_items() if can_use(state, it)]
    if not live:
        return None

    # 1. Instant defeat
    for it in live:
        if it.kind in ("defeat_hp", "defeat_atk") and can_use(state, it):
            return it

    incoming = expected_incoming(state)
    can_block_fully = incoming == 0 or (state.enemy_special != "pierce" and state.blk >= max(0, state.enemy_atk - state.atk_drop))

    # 2. Kill with ATK if possible
    atk_items = [it for it in live if it.kind in (
        "atk", "choose", "atk_hp_loss", "atk_7_hp", "atk_alt_24", "shield_alt",
        "atk_neighbor", "atk_cleave",
    ) and state.enemy_special != "no_atk_dmg"]
    total_atk = 0
    for it in atk_items:
        if it.kind == "atk":
            total_atk += int(it.ops.get("n", 0))
        elif it.kind == "choose" and it.id == "throwing_knife":
            total_atk += 3
        elif it.kind == "atk_hp_loss":
            total_atk += flail_atk(state)
        elif it.kind == "atk_7_hp":
            total_atk += 1 + max(0, state.player_hp_max - state.player_hp)
        elif it.kind == "atk_alt_24":
            total_atk += it.sai_val
        elif it.kind == "shield_alt" and it.shield_is_atk:
            total_atk += 3
        elif it.kind in ("atk_neighbor", "atk_cleave"):
            total_atk += int(it.ops.get("n", 4 if it.kind == "atk_neighbor" else 2))

    if state.enemy_special != "no_atk_dmg" and total_atk >= state.enemy_hp and atk_items:
        # Prefer knife throw if it alone kills
        for it in atk_items:
            if it.id == "throwing_knife" and state.enemy_hp <= 3:
                return it
        return atk_items[0]

    # 3. Fangs when dangerous and affordable
    fangs = next((it for it in live if it.kind == "fangs"), None)
    if fangs:
        fang_dmg, _ = incoming_damage(state)
        lethal = fang_dmg >= state.player_hp and not state.has_potion()
        if not lethal and (incoming >= state.player_hp or state.enemy_hp >= 4 or state.enemy_special in ("pierce", "blood_thresh", "impatient")):
            return fangs

    # 4. Net / Block to survive
    if incoming >= state.player_hp:
        nets = [it for it in live if it.id == "net"]
        if nets:
            return nets[0]
        blk_items = [it for it in live if it.kind in ("blk", "blk_keep", "blk_from_hp", "blk_min_hp", "flee_then_blk")
                     or (it.kind == "shield_alt" and not it.shield_is_atk)]
        if blk_items:
            return blk_items[0]
        if fangs and not (fang_dmg >= state.player_hp and not state.has_potion()):
            return fangs

    # 5. Pierce / kill-shot: cannot tank — must kill or Fangs/smoke
    if state.enemy_special in ("pierce", "kill_shot") and atk_items:
        return atk_items[0]
    if state.enemy_special in ("pierce", "kill_shot") and fangs:
        fang_dmg, _ = incoming_damage(state)
        if fang_dmg < state.player_hp or state.has_potion():
            return fangs
    if state.enemy_special in ("pierce", "kill_shot"):
        smoke = next((it for it in live if it.kind == "smoke"), None)
        if smoke:
            return smoke

    # 6. Chip or pad block if we have spare
    if atk_items and state.enemy_special != "no_atk_dmg":
        # Harpy: prefer killing fast over stacking block
        if state.enemy_special == "impatient":
            return atk_items[0]
        if not can_block_fully:
            blk_items = [it for it in live if it.kind in ("blk", "blk_keep", "blk_from_hp", "blk_min_hp", "flee_then_blk")]
            if blk_items and incoming > 0:
                return blk_items[0]
        return atk_items[0]

    blk_items = [it for it in live if it.kind in ("blk", "blk_keep", "blk_from_hp", "blk_min_hp", "flee_then_blk")]
    if blk_items and incoming > 0:
        return blk_items[0]

    heal = [it for it in live if it.kind in ("heal", "heal_keep", "heal_kills")]
    if heal and state.player_hp < state.player_hp_max:
        return heal[0]

    smoke = next((it for it in live if it.kind == "smoke"), None)
    if smoke and incoming >= state.player_hp:
        return smoke

    return None


def run_duel(
    loadout_specs: list[dict],
    monster: dict,
    hp_max: int = 6,
    hp_start: int = 6,
    rng: Optional[random.Random] = None,
    prior_hp_loss_events: int = 0,
    prior_mobs_defeated: int = 0,
    max_actions: int = 24,
) -> FightState:
    rng = rng or random.Random()
    state = FightState(
        player_hp=hp_start,
        player_hp_max=hp_max,
        hp_loss_events=prior_hp_loss_events,
        mobs_defeated=prior_mobs_defeated,
        items=[make_item(s) for s in loadout_specs],
    )
    start_fight(state, monster)
    if state.dead:
        return state

    actions = 0
    while actions < max_actions and state.enemy_alive and not state.dead and not state.escaped:
        pick = greedy_survive_policy(state, rng)
        if pick is None:
            resolve_done(state)
            break
        # Knife / Net choice hints
        choice = None
        if pick.id == "throwing_knife":
            choice = "throw" if state.enemy_hp > 1 else "nick"
            if state.enemy_hp <= 3:
                choice = "throw"
        elif pick.id == "net":
            need = max(0, (state.enemy_atk - state.atk_drop) - state.blk - (state.player_hp - 1))
            choice = "drop3" if need >= 3 else ("drop2" if need == 2 else "drop1")
        use_item(state, pick, rng, choice=choice)
        if state.enemy_special == "impatient" and state.enemy_alive and not state.dead and not state.escaped:
            harpy_item_swing(state)
        actions += 1
    else:
        if state.enemy_alive and not state.dead and not state.escaped:
            resolve_done(state)

    return state


def run_ladder(
    loadout_specs: list[dict],
    monsters: list[dict],
    hp_max: int = 6,
    rng: Optional[random.Random] = None,
) -> dict[str, Any]:
    rng = rng or random.Random()
    items = [make_item(s) for s in loadout_specs]
    hp = hp_max
    hp_loss_events = 0
    mobs_defeated = 0
    fights = []
    for mon in monsters:
        # rebuild specs from live item state
        specs = []
        for it in items:
            if it.spent:
                continue
            specs.append({
                "id": it.id,
                "name": it.name,
                "kind": it.kind,
                "ops": it.ops,
                "supported": it.supported,
            })
        st = run_duel(
            specs,
            mon,
            hp_max=hp_max,
            hp_start=hp,
            rng=rng,
            prior_hp_loss_events=hp_loss_events,
            prior_mobs_defeated=mobs_defeated,
        )
        fights.append({
            "monster": mon["id"],
            "won": st.won,
            "escaped": st.escaped,
            "dead": st.dead,
            "hp": st.player_hp,
            "turns": st.turns,
        })
        hp_loss_events = st.hp_loss_events
        mobs_defeated = st.mobs_defeated
        hp = st.player_hp
        # sync spent/keep onto durable item list by id (first match)
        remaining_ids = {it.id for it in st.items if not it.spent}
        for it in items:
            if it.id not in remaining_ids and not it.keep_flag:
                # spent this fight
                match = next((x for x in st.items if x.id == it.id), None)
                if match and match.spent:
                    it.spent = True
            # update sai / shield faces
            match = next((x for x in st.items if x.id == it.id and not x.spent), None)
            if match:
                it.sai_val = match.sai_val
                it.shield_is_atk = match.shield_is_atk
                it.lantern_n = match.lantern_n
                it.spent = match.spent
        if st.dead:
            break
    return {
        "cleared": all(f["won"] or f["escaped"] for f in fights) and len(fights) == len(monsters) and not any(f["dead"] for f in fights),
        "died_to": next((f["monster"] for f in fights if f["dead"]), None),
        "hp_end": hp,
        "fights": fights,
        "hp_loss_events": hp_loss_events,
    }
