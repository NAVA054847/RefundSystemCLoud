import React from 'react';
import { formatMoney, MONTH_NAMES } from './formatters';

/**
 * מלבן – פרטי ההכנסות של האזרח לפי שנים.
 */
function IncomesByYearCard({ incomesByYear }) {
  const hasData = incomesByYear && Object.keys(incomesByYear).length > 0;
  const entries = hasData
    ? Object.entries(incomesByYear).sort(([a], [b]) => Number(b) - Number(a))
    : [];

  return (
    <section className="bg-white rounded p-5 border border-gov-border">
      <h2 className="text-lg font-bold text-gov-blue mb-4 border-b-2 border-gov-blue pb-2 font-gov">פרטי ההכנסות של האזרח לפי שנים</h2>
      {!hasData ? (
        <p className="text-gov-text-muted text-sm font-gov">אין נתוני הכנסות.</p>
      ) : (
        <div className="space-y-4">
          {entries.map(([year, list]) => (
            <div key={year}>
              <h3 className="font-semibold text-gov-text mb-2 font-gov">שנת מס {year}</h3>
              <ul className="space-y-1 text-sm">
                {[...list]
                  .sort((a, b) => a.month - b.month)
                  .map((inc, i) => (
                    <li key={i} className="flex justify-between gap-3">
                      <span className="text-gov-text-muted">{MONTH_NAMES[inc.month] || inc.month}</span>
                      <span className="font-medium text-gov-text">{formatMoney(inc.amount)}</span>
                    </li>
                  ))}
              </ul>
            </div>
          ))}
        </div>
      )}
    </section>
  );
}

export default IncomesByYearCard;
