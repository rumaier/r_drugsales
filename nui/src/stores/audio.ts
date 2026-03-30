import { create } from "zustand";
import KeyPress from "../assets/sounds/keypress.ogg";

interface AudioPlayer {
  play: (sound: string, volume: number) => void;
  stop: (sound: string) => void;
};

export const useAudioStore = create<AudioPlayer>(() => {
  const audioRefs: { [key: string]: HTMLAudioElement } = {};

  const sounds: { [key: string]: string } = {
    keypress: KeyPress,
  };

  Object.keys(sounds).forEach((sound) => {
    audioRefs[sound] = new Audio(sounds[sound]);
  });

  return {
    play: (sound: string, volume: number) => {
      const audio = audioRefs[sound];
      if (audio) {
        audio.currentTime = 0;
        audio.volume = volume ?? 0.5;
        audio.play()
      } else {
        console.warn(`Sound "${sound}" not found`);
      };
    },
    stop: (sound: string) => {
      const audio = audioRefs[sound];
      if (audio) {
        audio.pause();
        audio.currentTime = 0;
      } else {
        console.warn(`Sound "${sound}" not found`);
      };
    }
  };
});