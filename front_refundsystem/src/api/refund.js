import axios from "axios";

const url = "https://localhost:7151/api/Refund";

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
