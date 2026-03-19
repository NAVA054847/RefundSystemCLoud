import { SET_USER, LOGOUT } from '../actions/authActions';

const initialState = {
  user: null,
};

export default function authReducer(state = initialState, action) {
  switch (action.type) {
    case SET_USER:
      return { ...state, user: action.payload };

    case LOGOUT:
      return { ...state, user: null };

      
    default:
      return state;
  }
}
