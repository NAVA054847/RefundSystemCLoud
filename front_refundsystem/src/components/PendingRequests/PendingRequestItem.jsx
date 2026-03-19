import React from 'react';
import { useNavigate } from 'react-router-dom';

/**
 * רכיב גנרי להצגת בקשה בודדת ממתינה לאישור.
 * לחיצה על הבקשה פותחת את מסך פרטי הבקשה (בקשת זכאות).
 */
function PendingRequestItem({ request }) {
  const navigate = useNavigate();
  const createdDate = request.createdAt
    ? new Date(request.createdAt).toLocaleDateString('he-IL', {
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
      })
    : '—';

  return (
    <article
      role="button"
      tabIndex={0}
      className="bg-white p-5 border border-gov-border rounded font-gov cursor-pointer hover:border-gov-blue hover:bg-gov-blue-light/30 transition"
      onClick={() => navigate(`/clerk/request/${request.requestId}`)}
      onKeyDown={(e) => e.key === 'Enter' && navigate(`/clerk/request/${request.requestId}`)}
    >
      <div className="flex justify-between gap-3 mb-2">
        <span className="text-gov-text-muted text-sm">שם מלא:</span>
        <span className="font-medium text-gov-text">{request.fullName}</span>
      </div>
      <div className="flex justify-between gap-3 mb-2">
        <span className="text-gov-text-muted text-sm">תעודת זהות:</span>
        <span className="font-medium text-gov-text" dir="ltr">{request.identityNumber}</span>
      </div>
      <div className="flex justify-between gap-3 mb-2">
        <span className="text-gov-text-muted text-sm">תאריך הבקשה:</span>
        <span className="font-medium text-gov-text">{createdDate}</span>
      </div>
      <div className="flex justify-between gap-3 mb-2">
        <span className="text-gov-text-muted text-sm">שנת מס:</span>
        <span className="font-medium text-gov-text">{request.taxYear}</span>
      </div>
      {request.calculatedAmount != null && (
        <div className="flex justify-between gap-3 mb-2">
          <span className="text-gov-text-muted text-sm">סכום מחושב:</span>
          <span className="font-medium text-gov-text">
            ₪{Number(request.calculatedAmount).toLocaleString('he-IL')}
          </span>
        </div>
      )}
      <div className="flex justify-between gap-3 mb-0">
        <span className="text-gov-text-muted text-sm">סטטוס:</span>
        <span className="font-medium text-gov-blue">{request.status}</span>
      </div>
    </article>
  );
}

export default PendingRequestItem;
