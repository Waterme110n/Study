//products
import React from 'react'
import { useDispatch, useSelector } from 'react-redux'
import { useCounter } from './counter'
import { orderItem } from './kursachRedux/action'

const ProductItem = ({ id, name, price, description, image }) => {
	const dispatch = useDispatch()
	const handleOrderClick = () => {
		dispatch(orderItem(id))
	}

	const { handleIncrement } = useCounter()
	const orderedItemIds = useSelector(state => state.orderedItemIds)
	console.log(orderedItemIds)

	return (
		<div className='modalDiv'>
			<img alt='' src={image} />
			<div>
				<h2>{name}</h2>
				<p className='ModalCost'>{price}$</p>
				<p className='ModalInfo'>{description}</p>
				<button
					onClick={() => {
						handleIncrement()
						handleOrderClick()
					}}
				>
					Order
				</button>
			</div>
		</div>
	)
}

export default ProductItem