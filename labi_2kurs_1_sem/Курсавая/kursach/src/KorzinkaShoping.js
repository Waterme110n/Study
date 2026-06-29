import React from 'react'
import { Link } from 'react-router-dom'
import './main.css'

import { FaMinus, FaPlus } from 'react-icons/fa'
import { ImCross } from 'react-icons/im'
import { PlantName } from './tovars'

import { useSelector } from 'react-redux'
import { useDispatch } from 'react-redux';
import { addItem, removeItem } from './kursachRedux/action';
import { createSelector } from 'reselect';

const getOrderedItemIds = (state) => state.orderedItemIds;

// Селектор для получения уникальных идентификаторов заказанных товаров
const getUniqueItemIds = createSelector(
  [getOrderedItemIds],
  (orderedItemIds) => Array.from(new Set(orderedItemIds))
);

// Селектор для получения количества заказанных товаров по идентификатору
const getOrderedItemsCount = createSelector(
  [getOrderedItemIds],
  (orderedItemIds) => {
    const orderedItemsCount = {};
    orderedItemIds.forEach((itemId) => {
      orderedItemsCount[itemId] = (orderedItemsCount[itemId] || 0) + 1;
    });
    return orderedItemsCount;
  }
);

// Селектор для вычисления общей стоимости заказа
export const calculateTotalPrice = createSelector(
  [getUniqueItemIds, getOrderedItemsCount],
  (uniqueItemIds, orderedItemsCount) => {
    let totalPrice = 0;
    uniqueItemIds.forEach((itemId) => {
      const quantity = orderedItemsCount[itemId];
      const selectedPlant = PlantName.find((plant) => plant.id === itemId);
      if (selectedPlant) {
        totalPrice += quantity * selectedPlant.price;
      }
    });
    return totalPrice;
  }
);

function ShopingHeader() {
	return (
		<header className='ShopingHeader'>
			<div className='UpHeader' id='top'>
				<h3>FREE SHIPPING ON ALL FULL SUN PLANTS! FEB. 25–28. </h3>
			</div>
			<div className='DownHeader'>
				<div className='logo'>
					Green <span>Thumb</span>
				</div>
				<ul className='menu'>
					<li>
						<Link to='/'>Home</Link>
					</li>
				</ul>
			</div>
		</header>
	)
}
function ShopingMain() {
	return (
		<div className='underHeader'>
			<h2>Shop</h2>
			<svg
				xmlns='http://www.w3.org/2000/svg'
				width='3vw'
				height='3vw'
				viewBox='0 0 4 48'
				fill='none'
			>
				<path
					d='M1 47L0.999998 1'
					stroke='black'
					stroke-linecap='round'
				/>
			</svg>
			<p>Find the perfect plant for your space</p>
		</div>
	)
}
function ShopingList() {
	const orderedItemIds = useSelector(state => state.orderedItemIds)
	const orderedItemsCount = {};
	const dispatch = useDispatch();

	orderedItemIds.forEach((itemId) => {
		orderedItemsCount[itemId] = (orderedItemsCount[itemId] || 0) + 1;
	  });

	  console.log('orderedItemIds: ', orderedItemIds);

	  const uniqueItemIds = Array.from(new Set(orderedItemIds));

	  const handleAddItem = (itemId) => {
		dispatch(addItem(itemId)); // Добавляем идентификатор в массив orderedItemIds
	  };
	
	  const handleRemoveItem = (itemId) => {
		if (orderedItemsCount[itemId] > 1) {
		  dispatch(removeItem(itemId)); // Удаляем один идентификатор из массива orderedItemIds
		}
	  };

	  const handleDeleteAllItems = (itemId) => {
		const itemIdsToDelete = orderedItemIds.filter((id) => id === itemId);
		itemIdsToDelete.forEach((id) => {
		  dispatch(removeItem(id)); 
		});
	  };


	  const calculateTotalPrice = () => {
		let totalPrice = 0;
		uniqueItemIds.forEach((itemId) => {
		  const quantity = orderedItemsCount[itemId];
		  const selectedPlant = PlantName.find((plant) => plant.id === itemId);
		  if (selectedPlant) {
			totalPrice += quantity * selectedPlant.price;
		  }
		});
		return totalPrice;
	  };

	  if (orderedItemIds.length === 0) {
		return <div>
			<p className='Nothing'>nothing ordered</p>
			<p className='NothingSec'><Link to='/'>back to store</Link></p>
		</div>
	  }

	return (
		<div className='ShopingBody'>
			{uniqueItemIds.map((item) => {
          	const selectedPlant = PlantName.find((plant) => plant.id === item);
          			if (!selectedPlant) return null;
					const quantity = orderedItemsCount[item]; 
					const totalPrice = quantity * selectedPlant.price;
					return (
						<div key={selectedPlant.id} className='product'>
						<img alt='' src={selectedPlant.PlantPhoto} />
						<h3>{selectedPlant.Pname}</h3>
						<div className='kolichProduct'>
						  <button onClick={() => handleAddItem(item)}>
							<FaPlus />
						  </button>
						  <p className='kolichOneProduct'>{quantity}</p>
						  <button onClick={() => handleRemoveItem(item)}>
							<FaMinus />
						  </button>
						</div>
						<p>$ {totalPrice}</p>
						<button onClick={() => handleDeleteAllItems(item)} className='delete' >
						  <ImCross />
						</button>
					  </div>
						
					)
				})}
			<div className='VsegoProducts'>
				<h3>AT All</h3>
				<p className='VsegoOneProduct'>{orderedItemIds.length}</p>
				<p className='Cena'>${calculateTotalPrice()}</p>
			</div>
		</div>
	)
}

function Korzina() {
	return (
		<div className='Korzina'>
			<ShopingHeader />
			<ShopingMain />
			<ShopingList />
		</div>
	)
}
export default Korzina
