//reducer
const initialState = {
	count: 0,
	orderedItemId: null,
	orderedItemIds: []
}

const reducer = (state = initialState, { type, payload }) => {
	switch (type) {
		case 'ORDER_ITEM':
			return {
				...state,
				orderedItemIds: [...state.orderedItemIds, payload]
			}
		case 'INCREMENT':
			return {
				...state,
				count: state.count + 1
			}
		case 'ADD_ITEM':
			return {
				...state,
				orderedItemIds: [...state.orderedItemIds, payload]
			};
		case 'REMOVE_ITEM':
			const index = state.orderedItemIds.findIndex((itemId) => itemId === payload);
			if (index !== -1) {
				const updatedOrderedItemIds = [...state.orderedItemIds];
				updatedOrderedItemIds.splice(index, 1);
				return {
				...state,
				orderedItemIds: updatedOrderedItemIds,
				};
			}
			return state;
		default:
		return state;
			
	}
	
}

export default reducer
