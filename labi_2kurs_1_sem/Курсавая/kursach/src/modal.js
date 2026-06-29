// ModalComponent.js
import React, { useState } from 'react'
import Modal from 'react-modal'
import './main.css'

import ProductItem from './Product'
import { PlantName } from './tovars'

const ModalComponent = () => {
	const [selectedPlant, setSelectedPlant] = useState(null)

	const openModal = plant => {
		setSelectedPlant(plant)
	}

	const closeModal = () => {
		setSelectedPlant(null)
	}

	return (
		<div className='BottomHotest'>
			{PlantName.map(item => (
				<div className='plant' key={item.id}>
					<img alt='' src={item.PlantPhoto} />
					<h3>{item.Pname}</h3>
					<p>{item.price}$</p>
					<button onClick={() => openModal(item)}>Buy</button>
				</div>
			))}
			<Modal
				isOpen={selectedPlant !== null}
				onRequestClose={closeModal}
				style={{
					overlay: {
						zIndex: 15,
						position: 'fixed',
						top: 0,
						left: 0,
						right: 0,
						bottom: 0,
						backgroundColor: 'rgba(255, 255, 255, 0.75)'
					},
					content: {
						zIndex: 15,
						position: 'absolute',
						top: '10vw',
						left: '18vw',
						right: '18vw',
						bottom: '10vw',
						border: '0.1vw solid #ccc',
						background: '#fff',
						overflow: 'hidden',
						WebkitOverflowScrolling: 'touch',
						borderRadius: '4px',
						outline: 'none',
						padding: '2vw',
						height: 'min-content'
					}
				}}
			>
				{selectedPlant && (
					<ProductItem
						id={selectedPlant.id}
						name={selectedPlant.Pname}
						price={selectedPlant.price}
						description={selectedPlant.PlantInfo}
						image={selectedPlant.PlantPhoto}
					/>
				)}
			</Modal>
		</div>
	)
}

export default ModalComponent
