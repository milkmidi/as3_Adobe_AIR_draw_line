const IS_MOBILE = device.mobile() || device.tablet();

export const CLICK = IS_MOBILE ? 'pointertap' : 'click';
export const MOUSE_DOWN = IS_MOBILE ? 'pointerdown' : 'mousedown';
export const MOUSE_UP = IS_MOBILE ? 'pointerup' : 'mouseup';
export const MOUSE_MOVE = IS_MOBILE ? 'pointermove' : 'mousemove';

