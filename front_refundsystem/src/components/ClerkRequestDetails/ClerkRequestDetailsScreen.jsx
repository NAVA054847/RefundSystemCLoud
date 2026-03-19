import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { useDispatch, useSelector } from 'react-redux';
import { getRequestDetails, approveOrRejectRequest, calculateRefund } from '../../api/refund';
import { logout } from '../../redux/actions/authActions';
import BudgetSidebar from './BudgetSidebar';
import IncomesByYearCard from './IncomesByYearCard';
import PastRequestsCard from './PastRequestsCard';
import CurrentRequestCard from './CurrentRequestCard';
import ClerkDecisionCard from './ClerkDecisionCard';

/**
 * מסך פרטי בקשת זכאות – נפתח בלחיצה על בקשה.
 * מרכיב: תקציב צד, הכנסות לפי שנים, בקשות עבר, פרטי הבקשה הנוכחית, החלטת הפקיד.
 */
function ClerkRequestDetailsScreen() {
  const { requestId } = useParams();
  const navigate = useNavigate();
  const user = useSelector((state) => state.auth.user);
  const dispatch = useDispatch();
  const [details, setDetails] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [approvedAmount, setApprovedAmount] = useState('');
  const [approveLoading, setApproveLoading] = useState(false);
  const [approveError, setApproveError] = useState(null);
  const [approveSuccess, setApproveSuccess] = useState(false);
  const [successType, setSuccessType] = useState(null);
  const [calculateLoading, setCalculateLoading] = useState(false);
  const [calculateError, setCalculateError] = useState(null);

  useEffect(() => {
    if (!user || user.role !== 'Clerk') navigate('/login');
  }, [user, navigate]);

  useEffect(() => {
    if (!requestId) return;
    let cancelled = false;

    async function fetchDetails() {
      setLoading(true);
      setError(null);
      try {
        const response = await getRequestDetails(requestId);
        if (!cancelled) setDetails(response.data);
      } catch (err) {
        if (!cancelled) setError(err.response?.status === 404 ? 'בקשה לא נמצאה' : (err.message || 'שגיאה בטעינת הפרטים'));
      } finally {
        if (!cancelled) setLoading(false);
      }
    }

    fetchDetails();
    return () => { cancelled = true; };
  }, [requestId]);

  if (!user || user.role !== 'Clerk') return null;

  if (loading) {
    return (
      <div className="w-full max-w-[900px] py-12 text-center text-gov-text-muted font-gov bg-gov-gray min-h-screen flex items-center justify-center" dir="rtl">
        <p>טוען פרטי בקשה...</p>
      </div>
    );
  }

  if (error || !details) {
    return (
      <div className="w-full max-w-[900px] text-right space-y-4 p-6 bg-gov-gray font-gov min-h-screen" dir="rtl">
        <p className="text-gov-error mb-4">{error || 'אין נתונים'}</p>
        <div className="flex gap-2">
          <button type="button" className="px-4 py-2 rounded border border-gov-border bg-white text-gov-text hover:bg-gov-gray font-medium font-gov" onClick={() => navigate('/clerk')}>חזרה לרשימה</button>
          <button type="button" className="px-4 py-2 rounded bg-gov-blue text-white font-semibold hover:bg-gov-blue-dark font-gov" onClick={() => { dispatch(logout()); navigate('/login'); }}>התנתק</button>
        </div>
      </div>
    );
  }

  const { currentRequest, incomes = [], pastRequests = [], currentMonthBudget } = details;

  const incomesByYear = incomes.reduce((acc, inc) => {
    const year = inc.taxYear;
    if (!acc[year]) acc[year] = [];
    acc[year].push(inc);
    return acc;
  }, {});

  const handleCalculate = async () => {
    if (!requestId) return;
    setCalculateError(null);
    setCalculateLoading(true);
    try {
      await calculateRefund(Number(requestId));
      const response = await getRequestDetails(requestId);
      setDetails(response.data);
    } catch (err) {
      const isServerError = err.response?.status >= 500;
      setCalculateError(isServerError
        ? 'לא ניתן לחשב את הזכאות. ייתכן שלא הוזנו לפחות 6 חודשי הכנסה לשנת המס של הבקשה.'
        : (err.response?.data?.message || err.response?.data?.title || err.message || 'שגיאה בחישוב הזכאות.'));
    } finally {
      setCalculateLoading(false);
    }
  };

  const handleApprove = async () => {
    const trimmed = approvedAmount.trim();
    if (trimmed === '') {
      setApproveError('יש להזין סכום לאישור.');
      return;
    }
    const amount = parseFloat(trimmed.replace(/,/g, ''));
    if (isNaN(amount) || amount < 0) {
      setApproveError('הזן סכום תקין (מספר חיובי).');
      return;
    }
    setApproveError(null);
    setApproveLoading(true);
    try {
      await approveOrRejectRequest(Number(requestId), true, amount);
      setSuccessType('approved');
      setApproveSuccess(true);
      setTimeout(() => navigate('/clerk'), 1500);
    } catch (err) {
      setApproveError('שגיאה באישור הבקשה. אם הסכום תקין, ייתכן שמדובר במשהו זמני – נסה שוב.');
    } finally {
      setApproveLoading(false);
    }
  };


  const handleReject = async () => {
    setApproveError(null);
    setApproveLoading(true);
    try {
      await approveOrRejectRequest(Number(requestId), false, null);
      setSuccessType('rejected');
      setApproveSuccess(true);
      setTimeout(() => navigate('/clerk'), 1500);
    } catch (err) {
      const status = err.response?.status;
      const serverMessage = err.response?.data?.message || err.response?.data?.title || err.message;
      setApproveError(status === 500 ? 'אירעה שגיאה בשרת בעת דחיית הבקשה. נסה שוב.' : (serverMessage || 'שגיאה בדחיית הבקשה'));
    } finally {
      setApproveLoading(false);
    }
  };

  return (
    <div className="w-full min-h-screen bg-gov-gray font-gov flex flex-col" dir="rtl">
      <div className="flex-1 flex gap-6 p-6 max-w-[1200px] w-full mx-auto">
        <main className="flex-1 min-w-0 text-right space-y-6">
          <div className="flex gap-2">
            <button type="button" className="px-4 py-2 rounded border border-gov-border bg-white text-gov-text hover:bg-gov-gray font-medium font-gov" onClick={() => navigate('/clerk')}>← חזרה לרשימה</button>
            <button type="button" className="px-4 py-2 rounded bg-gov-blue text-white font-semibold hover:bg-gov-blue-dark font-gov" onClick={() => { dispatch(logout()); navigate('/login'); }}>התנתק</button>
          </div>

          <IncomesByYearCard incomesByYear={incomesByYear} />
          <PastRequestsCard pastRequests={pastRequests} />
          <CurrentRequestCard currentRequest={currentRequest} />
        </main>

        {/* צד שמאל: קודם תקציב החודש, מתחתיו מלבן החלטת הפקיד (טור "דביק" שלא זז בגלילה) */}
        <aside className="w-64 shrink-0 flex flex-col gap-3 sticky top-6 self-start">
          <BudgetSidebar currentMonthBudget={currentMonthBudget} />
          <ClerkDecisionCard
            currentRequest={currentRequest}
            approvedAmount={approvedAmount}
            onApprovedAmountChange={setApprovedAmount}
            onApprove={handleApprove}
            onReject={handleReject}
            onCalculate={handleCalculate}
            calculateLoading={calculateLoading}
            calculateError={calculateError}
            loading={approveLoading}
            success={approveSuccess}
            successType={successType}
            error={approveError}
          />
        </aside>
      </div>
    </div>
  );
}

export default ClerkRequestDetailsScreen;
