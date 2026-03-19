import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { useDispatch, useSelector } from 'react-redux';
import PendingRequestItem from './PendingRequestItem';
import { getPendingRequests } from '../../api/refund';
import { logout } from '../../redux/actions/authActions';

/**
 * קומפוננטה גדולה: מבט על כל הבקשות הממתינות לאישור.
 * מכילה רשימה של רכיבים גנריים (PendingRequestItem) לכל בקשה.
 */
function PendingRequestsList() {
  const user = useSelector((state) => state.auth.user);
  const dispatch = useDispatch();
  const navigate = useNavigate();
  const [requests, setRequests] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    if (!user || user.role !== 'Clerk') navigate('/login');
  }, [user, navigate]);

  useEffect(() => {
    let cancelled = false;

    async function fetchPending() {
      setLoading(true);
      setError(null);
      try {
        const response = await getPendingRequests();
        const data = response.data;
        if (!cancelled) setRequests(Array.isArray(data) ? data : []);
      } catch (err) {
        if (!cancelled) {
          const msg = err.response?.data;
          setError(typeof msg === 'string' ? msg : (err.message || 'לא ניתן לטעון את הבקשות'));
        }
      } finally {
        if (!cancelled) setLoading(false);
      }
    }

    fetchPending();
    return () => { cancelled = true; };
  }, []);

  if (!user || user.role !== 'Clerk') return null;

  const logoutBtn = (
    <button type="button" className="px-4 py-2 rounded border border-gov-border bg-white text-gov-blue font-semibold hover:bg-gov-blue hover:text-white transition font-gov" onClick={() => { dispatch(logout()); navigate('/login'); }}>התנתק</button>
  );

  if (loading) {
    return (
      <div className="w-full min-h-screen flex flex-col items-center p-6 bg-gov-gray font-gov" dir="rtl">
        <div className="w-full max-w-[900px] flex justify-start mb-6">{logoutBtn}</div>
        <div className="w-full max-w-[900px] py-12 text-center text-gov-text-muted"><p>טוען בקשות...</p></div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="w-full min-h-screen flex flex-col items-center p-6 bg-gov-gray font-gov" dir="rtl">
        <div className="w-full max-w-[900px] flex justify-start mb-6">{logoutBtn}</div>
        <div className="w-full max-w-[900px] py-8 text-center text-gov-error"><p>{error}</p></div>
      </div>
    );
  }

  if (requests.length === 0) {
    return (
      <div className="w-full min-h-screen flex flex-col items-center p-6 bg-gov-gray font-gov" dir="rtl">
        <div className="w-full max-w-[900px] flex justify-start mb-6">{logoutBtn}</div>
        <div className="w-full max-w-[900px] py-12 text-center text-gov-text-muted"><p>אין בקשות ממתינות לאישור.</p></div>
      </div>
    );
  }

  return (
    <div className="w-full min-h-screen flex flex-col items-center p-6 bg-gov-gray font-gov" dir="rtl">
      <div className="w-full max-w-[900px] flex justify-start mb-6">{logoutBtn}</div>
      <div className="w-full max-w-[900px] text-right">
      <h2 className="mb-4 text-xl font-bold text-gov-blue border-b-2 border-gov-blue pb-2">בקשות ממתינות לאישור</h2>
      <ul className="list-none m-0 p-0 flex flex-col gap-4">
        {requests.map((request) => (
          <li key={request.requestId}>
            <PendingRequestItem request={request} />
          </li>
        ))}
      </ul>
      </div>
    </div>
  );
}

export default PendingRequestsList;
