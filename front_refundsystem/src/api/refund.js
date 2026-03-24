import axios from "axios";

//כתובת של השרת המקומי
//const url = "https://localhost:7151/api/Refund";

//כתובת של השר בענן
const url = "https://refund-system-api-495207073032.us-central1.run.app/api/Refund";

export const getPendingRequests = () => {
  return axios.get(`${url}/pending`);
};

export const getRequestDetails = (requestId) => {
  return axios.get(`${url}/${requestId}`);
};

export const calculateRefund = (requestId) => {
  return axios.post(`${url}/${requestId}/calculate`);
};

export const approveOrRejectRequest = (requestId, isApproved, approvedAmount = null) => {
  return axios.post(`${url}/approve`, { requestId, isApproved, approvedAmount });
};

export const getCitizenRequestView = (identityNumber) => {
  return axios.get(`${url}/citizen/${encodeURIComponent(identityNumber)}`);
};
