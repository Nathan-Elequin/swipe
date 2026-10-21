from PIL import Image
P={'.':(0,0,0,0),'k':(16,14,12,255),'Y':(255,216,74,255),'W':(255,243,214,255),'L':(197,205,216,255),'M':(138,138,156,255),
   'S':(92,100,116,255),'D':(58,58,68,255),'C':(26,18,16,255),'e':(255,216,74,255),'o':(240,154,52,255)}
G=["...kkkkk...",
   "..kYYkMMk..",
   ".kYLLeLMSk.",
   "kYLLLCMMMSk",
   "kYLLWCWMMSk",
   "kkeCCWCCekk",
   "kLLMWCWMSSk",
   "kMMMMCMSSDk",
   ".kMMSeSSDk.",
   "..kSSkSDk..",
   "...kkkkk..."]
im=Image.new('RGBA',(11,11))
for y,r in enumerate(G):
    for x,c in enumerate(r): im.putpixel((x,y),P[c])
im.save('logo/dotC_hand.png'); im.resize((132,132),0).save('/tmp/hc.png')
