import axios from "axios";

const url = "https://localhost:7151/api/Auth";

export const login = (identityNumber) => {
  return axios.post(`${url}/login`, { identityNumber });
};
