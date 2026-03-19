import React from 'react';
import { formatMoney, formatDate } from '../ClerkRequestDetails/formatters';

/**
 * מלבן – היסטוריית הבקשות של האזרח (ללא הבקשה האחרונה).
 */
function CitizenHistoryCard({ history = [] }) {
  return (
    <section className="bg-white border border-gov-border rounded p-5">
      <h2 className="text-lg font-bold text-gov-blue mb-4 border-b-2 border-gov-blue pb-2">היסטוריית הבקשות שלי</h2>
      {history.length === 0 ? (
        <p className="text-gov-text-muted text-sm">אין בקשות נוספות.</p>
      ) : (
        <ul className="space-y-3">
          {history.map((req) => (
            <li key={req.requestId} className="border-b border-gov-border pb-3 last:border-0 last:pb-0">
              <div className="flex flex-wrap justify-between gap-2 text-sm">
                <span className="text-gov-text-muted">בקשה #{req.requestId}</span>
                <span className="font-medium text-gov-text">שנת מס {req.taxYear}</span>
              </div>
              <div className="flex flex-wrap justify-between gap-2 text-sm mt-1">
                <span className="text-gov-text-muted">גובה הזכאות / ההחזר שאושר:</span>
                <span className="font-medium text-gov-success">{formatMoney(req.approvedAmount ?? req.calculatedAmount)}</span>
              </div>
              <div className="flex flex-wrap justify-between gap-2 text-sm mt-1">
                <span className="text-gov-text-muted">סטטוס</span>
                <span className="font-medium text-gov-text">{req.status}</span>
                <span className="text-gov-text-muted">{formatDate(req.createdAt)}</span>
              </div>
            </li>
          ))}
        </ul>
      )}
    </section>
  );
}

export default CitizenHistoryCard;
