let player;
let isLoop = true;
let eventCallback = null;

// Initialize player
export function initPlayer(playlist = '', callback = null) {
  // store consumer callback
  eventCallback = callback;

  player = new YT.Player('youtube-player', {
    height: '0', // invisible
    width: '0',
    playerVars: {
      'controls': 0,     // hide controls
      'playlist': playlist
    },
    events: {
      'onReady': onPlayerReady,
      'onStateChange': onPlayerStateChange
    }
  });
}

function onPlayerReady(event) {
  console.log('YouTube player ready!');
  event.target.setLoop(isLoop);
}

function onPlayerStateChange(event) {
  const stateMap = {
    0: 'ended',
    1: 'playing',
    2: 'paused',
    3: 'buffering',
    5: 'cued'
  };
  const state = stateMap[event.data];
  console.log('Player state', state);
  if (typeof eventCallback === 'function' && state) {
    eventCallback(state, {
      videoId: player.getVideoData().video_id,
      title: player.getVideoData().title
    });
  }
}

// control player
export function playVideo() {
  if (typeof player?.playVideo === 'function') {
    console.log("Youtube API play");
    player.playVideo();
  }
}

export function pauseVideo() {
  console.log("Youtube API pause");
  player.pauseVideo();
}

export function nextVideo() {
  console.log("Youtube API next");
  player.nextVideo();
}

export function previousVideo() {
  console.log("Youtube API previous");
  player.previousVideo();
}

export function playLists(videoIds, startIndex = 0) {
  console.log("Youtube API set playlist", videoIds);
  if(player.loadPlaylist) {
    player.loadPlaylist({ playlist: videoIds, index: startIndex });
    player.setLoop(isLoop);
  }
}

export function toggleLoop() {
  isLoop = !isLoop;
  console.log("Loop:", isLoop);
  if(player.setLoop) player.setLoop(isLoop);
  return isLoop;
}

export function getCurrentTime() {
  if (typeof player?.getCurrentTime !== 'function') return 0;
  return player.getCurrentTime();
}

export function getDuration() {
  if (typeof player?.getDuration !== 'function') return 0;
 return player.getDuration();
}

export function seekTo(percent) {
  if (typeof player?.getDuration !== 'function') return;
  const time = percent * player.getDuration();
  console.log('Seek to', time);
  player.seekTo(time, true);
}

export function seekToTime(time) {
  if (typeof player?.seekTo !== 'function') return;
  console.log('Seek to', time);
  player.seekTo(time, true);
}

export function getPlaylistIndex() {
  if (typeof player?.getPlaylistIndex !== 'function') return;
  return player.getPlaylistIndex();
}