// actions.js
export const ADD_ITEM = 'ADD_ITEM';
export const REMOVE_ITEM = 'REMOVE_ITEM';

export const increment = () => ({
	type: 'INCREMENT'
})
export const orderItem = itemId => {
	return {
		type: 'ORDER_ITEM',
		payload: itemId
	}
}

export const addItem = (itemId) => {
	return {
	  type: ADD_ITEM,
	  payload: itemId,
	};
  };

  export const removeItem = (itemId) => {
	return {
	  type: REMOVE_ITEM,
	  payload: itemId,
	};
  };