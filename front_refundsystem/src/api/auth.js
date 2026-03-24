import axios from "axios";

//כתובת של השרת המקומי
//const url = "https://localhost:7151/api/Auth";

//כתובת של הענן בארהב
const url = "https://refund-system-api-495207073032.us-central1.run.app/api/Auth";


export const login = (identityNumber) => {
  return axios.post(`${url}/login`, { identityNumber });
};
