import { Route, Routes } from 'react-router-dom';
import LoginPage from './components/LoginPage';
import CitizenScreen from './components/CitizenScreen/CitizenScreen';
import ClerkRequestDetailsScreen from './components/ClerkRequestDetails/ClerkRequestDetailsScreen';
import PendingRequestsList from './components/PendingRequests/PendingRequestsList';

function AppRouter() {
  return (
    <Routes>
      <Route path="/" element={<LoginPage />} />
      <Route path="/login" element={<LoginPage />} />
      <Route path="/citizen" element={<CitizenScreen />} />
      <Route path="/clerk" element={<PendingRequestsList />} />
      <Route path="/clerk/request/:requestId" element={<ClerkRequestDetailsScreen />} />
    </Routes>
  );
}

export default AppRouter;
