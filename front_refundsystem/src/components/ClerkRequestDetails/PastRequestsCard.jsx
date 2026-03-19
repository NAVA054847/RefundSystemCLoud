import React from 'react';
import { formatMoney, formatDate } from './formatters';

/**
 * מלבן – בקשות עבר של האזרח (כולל ההחזר שהתקבל).
 */
function PastRequestsCard({ pastRequests = [] }) {
  const hasData = pastRequests && pastRequests.length > 0;

  return (
    <section className="bg-white rounded p-5 border border-gov-border">
      <h2 className="text-lg font-bold text-gov-blue mb-4 border-b-2 border-gov-blue pb-2 font-gov">בקשות עבר של האזרח (כולל ההחזר שהתקבל)</h2>
      {!hasData ? (
        <p className="text-gov-text-muted text-sm font-gov">אין בקשות עבר.</p>
      ) : (
        <ul className="space-y-3">
          {pastRequests.map((req) => (
            <li key={req.requestId} className="border-b border-gov-border pb-3 last:border-0 last:pb-0">
              <div className="flex flex-wrap justify-between gap-2 text-sm">
                <span className="text-gov-text-muted">בקשה #{req.requestId}</span>
                <span className="font-medium text-gov-text font-gov">שנת מס {req.taxYear}</span>
              </div>
              <div className="flex flex-wrap justify-between gap-2 text-sm mt-1">
                <span className="text-gov-text-muted">ההחזר שהתקבל:</span>
                <span className="font-medium text-gov-success font-gov">{formatMoney(req.approvedAmount)}</span>
              </div>
              <div className="flex flex-wrap justify-between gap-2 text-sm">
                <span className="text-gov-text-muted">סטטוס:</span>
                <span className="font-medium text-gov-text font-gov">{req.status}</span>
                <span className="text-gov-text-muted font-gov">{formatDate(req.createdAt)}</span>
              </div>
            </li>
          ))}
        </ul>
      )}
    </section>
  );
}

export default PastRequestsCard;
