---
title: Robot Logs 0
date: "2026-04-09T12:00:00.000Z"
description: "Always blame the hardware"
---

A low herz of emitting velocity commands can lead to poor behavior in a face tracking robot.

Camera feed 15hz but robot only emitting `cmd_vel` at 2 to 3 hz resulted in a tracker that wandered around, often moving the face entirely out of frame, and getting stick in a "look up and to the right" position.

Initial ideas: maybe training had issues (poor sim to real transfer) and we need more complex or realistic sim environments. Claude proposed we may need to tweak max acceleration or velocity, but that didn't help.

Solution: moved inference to my laptop which can easily handle 15hz. Pi robot publishes camera+command frames to laptop -> laptop runs inference on frame -> laptop publishes velocity to Pi.

Result: Solid face tracking, accurate for single and multiple faces. Even tracks a beaver drawn on a bag of toothpicks!

![Camera pointing at a bag with a picture of a beaver wearing a hat and chewing a toothpick](./camera_beaver_toothpick_hat.png)

The robot's command  here was "look at the person wearing a hat". It did track the beaver in a hat instead of me. Success! (Whether or not a beaver should be considered a "person" is beyond the scope of this article.)