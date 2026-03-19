import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useDispatch } from 'react-redux';
import { setUser } from '../redux/actions/authActions';
import { login } from '../api/auth';

function LoginPage() {
  const dispatch = useDispatch();
  const navigate = useNavigate();
  const [identityNumber, setIdentityNumber] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const handleSubmit = async (event) => {
    event.preventDefault();
    setError('');

    const trimmedIdentity = identityNumber.trim();

    if (!trimmedIdentity) {
      setError('יש להזין תעודת זהות.');
      return;
    }

    setLoading(true);

    try {
      const response = await login(trimmedIdentity);
      const data = response.data;

      if (!data || !data.role) {
        setError('תגובת שרת לא תקינה.');
        return;
      }

      dispatch(setUser({ ...data, identityNumber: trimmedIdentity }));
      const role = data.role || '';
      if (role === 'Citizen') navigate('/citizen');
      else if (role === 'Clerk') navigate('/clerk');
      else setError('תפקיד משתמש לא מוכר.');
    } catch (err) {
      if (err.response?.status === 404) {
        setError('לא נמצא משתמש עם תעודת זהות זו.');
      } else if (err.response?.status >= 400) {
        setError('אירעה שגיאה בזמן ההתחברות. נסה שוב מאוחר יותר.');
      } else {
        setError('לא ניתן להתחבר לשרת. ודא שה־API פעיל.');
      }
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="w-full min-h-screen flex items-center justify-center p-6 bg-gov-gray font-gov" dir="rtl">
      <div className="w-full max-w-[440px] bg-white border border-gov-border rounded p-8 shadow-sm">
        <h1 className="text-2xl font-bold text-gov-blue border-b-2 border-gov-blue pb-3 mb-6">
          התחברות למערכת ההחזרים
        </h1>
        <form className="flex flex-col gap-4" onSubmit={handleSubmit}>
          <label htmlFor="identityNumber" className="text-sm font-medium text-gov-text">
            תעודת זהות
          </label>
          <input
            id="identityNumber"
            type="text"
            className="w-full px-3 py-2.5 border border-gov-border rounded font-gov outline-none focus:border-gov-blue focus:ring-2 focus:ring-gov-blue/20"
            value={identityNumber}
            onChange={(e) => setIdentityNumber(e.target.value)}
            placeholder="הכנס תעודת זהות"
            autoComplete="off"
            dir="ltr"
          />
          {error && <p className="text-sm text-gov-error py-1">{error}</p>}
          <button
            type="submit"
            disabled={loading}
            className="mt-2 px-5 py-3 rounded bg-gov-blue text-white font-semibold font-gov hover:bg-gov-blue-dark disabled:opacity-70 disabled:cursor-not-allowed transition"
          >
            {loading ? 'מתחבר...' : 'התחבר'}
          </button>
        </form>
      </div>
    </div>
  );
}

export default LoginPage;
