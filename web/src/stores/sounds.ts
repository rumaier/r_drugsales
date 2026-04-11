import { create } from "zustand";

interface SoundStore {
  play: (sound: string, volume?: number) => void;
  stop: (sound: string) => void;
};

interface SoundRef {
  [key: string]: HTMLAudioElement;
};

interface Sound {
  [key: string]: string;
}

export const useSoundStore = create<SoundStore>(() => {
  const refs: SoundRef = {};
  const sounds: Sound = {};
  Object.keys(sounds).forEach((sound) => {
    refs[sound] = new Audio(sounds[sound]);
  });

  return {
    play: (sound: string, volume: number = 1.0) => {
      const audio = refs[sound];
      if (audio) {
        audio.currentTime = 0;
        audio.volume = volume;
        audio.play();
      } else {
        console.warn(`Sound ${sound} not found`);
      };
    },

    stop: (sound: string) => {
      const audio = refs[sound];
      if (audio) {
        audio.pause();
      } else {
        console.warn(`Sound ${sound} not found`);
      }; 
    }
  };
});