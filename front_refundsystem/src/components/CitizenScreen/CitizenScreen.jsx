import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useDispatch, useSelector } from 'react-redux';
import { logout } from '../../redux/actions/authActions';
import { getCitizenRequestView } from '../../api/refund';
import CitizenLastRequestCard from './CitizenLastRequestCard';
import CitizenHistoryCard from './CitizenHistoryCard';

function CitizenScreen() {
  const user = useSelector((state) => state.auth.user);
  const dispatch = useDispatch();
  const navigate = useNavigate();
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    if (!user || user.role !== 'Citizen') navigate('/login');
  }, [user, navigate]);

  useEffect(() => {
    if (!user || user.role !== 'Citizen') {
      setLoading(false);
      return;
    }
    if (!user.identityNumber) {
      setError('לא ניתן לטעון נתונים. אנא התנתק והתחבר מחדש עם תעודת הזהות.');
      setLoading(false);
      return;
    }

    let cancelled = false;
    setLoading(true);
    setError('');

    getCitizenRequestView(user.identityNumber)
      .then((res) => {
        if (!cancelled && res.data) setData(res.data);
      })
      .catch((err) => {
        if (cancelled) return;
        if (err.response?.status === 404) setError('לא נמצאו בקשות עבור תעודת זהות זו.');
        else setError('אירעה שגיאה בטעינת הנתונים. נסה שוב מאוחר יותר.');
      })
      .finally(() => {
        if (!cancelled) setLoading(false);
      });

    return () => { cancelled = true; };
  }, [user?.id, user?.identityNumber]);

  if (!user || user.role !== 'Citizen') return null;

  const requests = data?.requests ?? [];
  const lastRequest = requests[0] ?? null;
  const history = requests.length > 1 ? requests.slice(1) : [];

  return (
    <div className="w-full min-h-screen bg-gov-gray font-gov p-6" dir="rtl">
      <div className="max-w-2xl mx-auto space-y-6">
        <header className="bg-white border border-gov-border rounded p-6 flex flex-wrap items-center justify-between gap-4">
          <div>
            <h1 className="text-2xl font-bold text-gov-blue">שלום {user.fullName}</h1>
            <p className="text-gov-text mt-1">ברוך הבא למסך האזרח</p>
          </div>
          <button
            type="button"
            className="px-5 py-2.5 rounded bg-gov-blue text-white font-semibold hover:bg-gov-blue-dark transition"
            onClick={() => { dispatch(logout()); navigate('/login'); }}
          >
            התנתק
          </button>
        </header>

        {loading && (
          <p className="text-gov-text text-center py-8">טוען נתונים...</p>
        )}

        {error && (
          <section className="bg-white border border-gov-border rounded p-5">
            <p className="text-gov-error font-medium">{error}</p>
          </section>
        )}

        {!loading && !error && lastRequest && (
          <CitizenLastRequestCard lastRequest={lastRequest} />
        )}

        {!loading && !error && (
          <CitizenHistoryCard history={history} />
        )}

        {!loading && !error && requests.length === 0 && (
          <section className="bg-white border border-gov-border rounded p-5">
            <p className="text-gov-text-muted">לא נמצאו בקשות עבור תעודת זהות זו.</p>
          </section>
        )}
      </div>
    </div>
  );
}

export default CitizenScreen;
