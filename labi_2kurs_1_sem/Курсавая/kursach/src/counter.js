import { useSelector, useDispatch } from 'react-redux';
import { increment} from './kursachRedux/action'; 


export const useCounter  = () => {
  const count = useSelector(state => state.count);
  const dispatch = useDispatch();

  const handleIncrement = () => {
    dispatch(increment());
  };
  return {
    count,
    handleIncrement,
  };
}
