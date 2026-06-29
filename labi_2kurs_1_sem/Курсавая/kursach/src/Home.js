import './main.css';

import korz from '../src/photo/korz.png'

import LeftFlower from '../src/photo/image 22.png'
import RightFlower from '../src/photo/image 21.png'

import bonsai from '../src/photo/bonsai.png'
import kaktus from '../src/photo/kaktus.png'
import creepers from '../src/photo/creepers.png'
import succulents from '../src/photo/succulents.png'
import seeds from '../src/photo/seeds.png'
import gifts from '../src/photo/gifts.png'

import indoor from '../src/photo/indoor.jpg'
import air from '../src/photo/air.jpg'
import flowering from '../src/photo/flowering.jpg'

import { AiFillYoutube } from "react-icons/ai";
import { BiLogoFacebook } from "react-icons/bi";
import { AiOutlineTwitter } from "react-icons/ai";
import { AiOutlineInstagram } from "react-icons/ai";

import React, {  useEffect,useState } from 'react';
import ModalComponent from './modal'; 

import { Link } from "react-router-dom"

import { useSelector } from 'react-redux';


/*--хук--*/
function useScrollToPosition(position) {
  useEffect(() => {
    const handleScroll = () => {
      const windowHeight = window.innerHeight;
      const scrollToPosition = (windowHeight * position) / 100;
      window.scrollTo({ top: scrollToPosition, behavior: 'smooth' });
    };

    const button = document.getElementById('scrollButton');
    button.addEventListener('click', handleScroll);

    return () => {
      button.removeEventListener('click', handleScroll);
    };
  }, [position]);
}
/*переиспользование кода*/
/*кастомный хук*/
function useTextAnimation() {
  const [hoveredIndex, setHoveredIndex] = useState(-1);

  const handleMouseEnter = (index) => {
    setHoveredIndex(index);
  };

  const handleMouseLeave = () => {
    setHoveredIndex(-1);
  };

  const getAnimatedStyle = (index) => {
    if (index === hoveredIndex && index % 2 === 0) {
      return {
        fontSize: '1.4vw',
      };
    }else if(index === hoveredIndex && index % 2 !== 0) {
      return {
        letterSpacing: '0.4vw',
      };
    }

    return {};
  };

  return { handleMouseEnter, handleMouseLeave, getAnimatedStyle };
}

const handleLinkClick = (e, sectionId) => {
  // Проверяем, находится ли секция на текущей странице
  const section = document.getElementById(sectionId);
  if (section) {
    e.preventDefault();

    // Выполняем плавную прокрутку к секции
    window.scrollTo({
      top: section.offsetTop,
      behavior: 'smooth'
    });
  }
};

function HeaderEveryStr(){  

  const orderedItemIds = useSelector(state => state.orderedItemIds)
  console.log('orderedItemIds: ', orderedItemIds);

  return (
    <header >
        <div className="UpHeader" id='top'>
          <h3>FREE SHIPPING ON ALL FULL SUN PLANTS! FEB. 25–28. </h3>
        </div>
        <div className="DownHeader">
          <div className="logo">Green <span>Thumb</span></div>
          <ul className="menu">
            <li><Link to="/" onClick={(e) => handleLinkClick(e, 'top')} activeClassName="active">Home</Link></li>
            <li><Link to="/" onClick={(e) => handleLinkClick(e, 'Products')} activeClassName="active">Products</Link></li>
            <li><Link to="/" onClick={(e) => handleLinkClick(e, 'foot')} activeClassName="active">About us</Link></li>
            <li><Link to="/" onClick={(e) => handleLinkClick(e, 'foot')} activeClassName="active">Contact us</Link></li>
          </ul>
          <Link to="/Korzina">
          <div className="SearchAndShop">
            <img alt="" src={korz} className="korz"/>
            <p className="Number">{orderedItemIds.length}</p>
          </div>
          </Link>
        </div>
    </header>
  )
}
function Main(){
  useScrollToPosition(110)
  return(
    <div className="top" >
      <img alt="" src={LeftFlower} className="LeftFlower"/>
      <img alt="" src={RightFlower} className="RightFlower"/>
      <div className="TopCenter">
        <h3>Plants are <br/>our Passion</h3>
        <p>Even if you don’t have a green thumb,<br/> you can still have a green home.</p>
        
        <button id="scrollButton" ><a href>Get Planting</a></button>
      </div>
      <div className="TopEnd"></div>
    </div>
  )
}
function Category(){
  const { handleMouseEnter, handleMouseLeave, getAnimatedStyle } = useTextAnimation();
  const categories = [
    { id: 1, name: 'BONSAI', photo: bonsai},
    { id: 2, name: 'Cacti', photo: kaktus },
    { id: 3, name: 'CREEPERS', photo: creepers },
    { id: 4, name: 'Succulents', photo: succulents },
    { id: 5, name: 'seeds', photo: seeds },
    { id: 6, name: 'Gifts', photo: gifts },
  ];
  
  return (
    <div className="Category">
      <h3>
        <span>Shop</span> by Category
      </h3>
      <hr />
      <div className="categories">
      {categories.map((category, index) => (
        <div
          key={category.id}
          onMouseEnter={() => handleMouseEnter(index)}
          onMouseLeave={handleMouseLeave}
        >
          <img alt="" src={category.photo} className={category.name.toLowerCase()} />
          <h2 style={getAnimatedStyle(index)}>{category.name}</h2>
        </div>
      ))}
      </div>
    </div>
  );
}
function Selling(){
  return(
    <div className="Selling">
      <div className="TopSelling">
        <h3><span>Best</span> Selling</h3>
      </div>
       <hr/>
       <div className='BottomSelling'>
        <div>
          <img alt="" src={indoor}/>
          <p>Indoor <br/> Plants</p>
          <button><Link to="/" onClick={(e) => handleLinkClick(e, 'Products')} activeClassName="active">Shop Now</Link></button>
        </div>
        <div>
          <img alt="" src={air}/>
          <p>Air Purifying <br/>  Plants</p>
          <button><Link to="/" onClick={(e) => handleLinkClick(e, 'Products')} activeClassName="active">Shop Now</Link></button>
        </div>
        <div>
          <img alt="" src={flowering}/>
          <p>Flowering <br/>  Plants</p>
          <button><Link to="/" onClick={(e) => handleLinkClick(e, 'Products')} activeClassName="active">Shop Now</Link></button>
        </div>
       </div>
    </div>
  )
}
function Hottest(){
  return(
    <div className='Hottest' id='Products'>
      <div className="TopHottest" >
        <h3><span>Hottest</span> Plants</h3>
      </div>
      <hr/>
      <ModalComponent />
    </div>
  )
}
function Footer(){
  return(
    <footer id='foot'>
      <div className='topFooter'>
        <div className='topTopFooter'>
          <p>Products</p>
          <p>Returns</p>
          <p>About us</p>
          <p>Contact us</p>
        </div>
        <div className='TopBottomFooter'>
          <AiFillYoutube size="1.4vw"/>
          <BiLogoFacebook size="1.4vw"/>
          <AiOutlineTwitter size="1.4vw"/>
          <AiOutlineInstagram size="1.4vw"/>
        </div>
      </div>
      <div className='BottFooter'>

      </div>

    </footer>
  )
}
function Home() {
  return (
    <div className="Home">
        <HeaderEveryStr />
        <Main />
        <Category />
        <Selling />
        <Hottest />
        <Footer />
    </div>
    
  );
}

export default Home;