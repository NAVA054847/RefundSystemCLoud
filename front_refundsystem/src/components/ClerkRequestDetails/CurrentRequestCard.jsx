import React from 'react';
import { formatMoney, formatDate } from './formatters';

/**
 * מלבן – פרטי הבקשה הנוכחית.
 */
function CurrentRequestCard({ currentRequest }) {
  if (!currentRequest) return null;

  return (
    <section className="bg-white rounded p-5 border border-gov-border">
      <h2 className="text-lg font-bold text-gov-blue mb-4 border-b-2 border-gov-blue pb-2 font-gov">פרטי הבקשה הנוכחית</h2>
      <ul className="space-y-2 text-sm">
        <li className="flex justify-between gap-3">
          <span className="text-gov-text-muted">מזהה בקשה</span>
          <span className="font-medium text-gov-text">{currentRequest.requestId}</span>
        </li>
        <li className="flex justify-between gap-3">
          <span className="text-gov-text-muted">שנת מס</span>
          <span className="font-medium text-gov-text">{currentRequest.taxYear}</span>
        </li>
        <li className="flex justify-between gap-3">
          <span className="text-gov-text-muted">סכום מחושב</span>
          <span className="font-medium text-gov-text">{formatMoney(currentRequest.calculatedAmount)}</span>
        </li>
        <li className="flex justify-between gap-3">
          <span className="text-gov-text-muted">סכום שאושר</span>
          <span className="font-medium text-gov-text">{formatMoney(currentRequest.approvedAmount)}</span>
        </li>
        <li className="flex justify-between gap-3">
          <span className="text-gov-text-muted">סטטוס</span>
          <span className="font-medium text-gov-blue">{currentRequest.status}</span>
        </li>
        <li className="flex justify-between gap-3">
          <span className="text-gov-text-muted">תאריך יצירה</span>
          <span className="font-medium text-gov-text">{formatDate(currentRequest.createdAt)}</span>
        </li>
      </ul>
    </section>
  );
}

export default CurrentRequestCard;
