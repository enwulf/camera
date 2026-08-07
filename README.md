Take a photo: `/function camera:shot`

## How

`photo.json` is a post chain, five passes. Two of its targets are `persistent` so they
survive between frames, that's the whole trick. A shader only ever sees the current frame
otherwise. `photo_capture` writes the live scene for 0.05s and after that keeps writing
back what it already holds. The rest is `state_clock` counting from the start time.

Retriggering was the annoying part. There's no packet for "restart this effect", so the
shutter alternates two chains that put a different byte in pixel (0,0), and the clock
restarts when the byte changes.

Worth knowing:

- the server batches the effect list and sends it once at end of tick, so a clear and an
  add in the same tick arrive as one change. The chain never stops, the clock never
  restarts.
- a shader can't tell a gap in rendering from a pause. Restart on the gap and photos
  start taking themselves on unpause.

`/posteffect add` doesn't check the chain exists, it just skips. If nothing happens,
check the log for `Requested post effect does not exist`.

The image sits in a GPU target. Client side, no readback to the server.
