"""Path config for the PixelLab toolkit. Nothing here is secret.
PL_RUN_DIR      working dir for one batch (raw/, base/, work/, final/, showcase/, calls.log). Default: current dir.
                Keep it OUTSIDE the repo (e.g. ~/pl-runs/run5) and only commit finals + contact sheets.
PL_ART_SOURCE   old runs (run2/run3/run4) used as init images / refs. Default: ../art-source next to this folder.
PL_PALETTE      palette .hex. Default: ../palette/spinheritance.hex next to this folder.
"""
import os
HERE = os.path.dirname(os.path.abspath(__file__))
RUN_DIR = os.path.abspath(os.environ.get('PL_RUN_DIR', os.getcwd()))
ART_SOURCE = os.path.abspath(os.environ.get('PL_ART_SOURCE', os.path.join(HERE, '..', 'art-source')))
PALETTE_HEX = os.path.abspath(os.environ.get('PL_PALETTE', os.path.join(HERE, '..', 'palette', 'spinheritance.hex')))
