export const SET_USER = 'auth/SET_USER';
export const LOGOUT = 'auth/LOGOUT';

export function setUser(user) {
  return { type: SET_USER, payload: user };
}

export function logout() {
  return { type: LOGOUT };
}
