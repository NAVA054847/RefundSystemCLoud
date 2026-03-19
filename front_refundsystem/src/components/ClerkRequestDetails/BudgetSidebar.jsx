import React from 'react';
import { formatMoney } from './formatters';

/**
 * קומפוננטה נפרדת שמציגה רק את מלבן תקציב החודש הנוכחי.
 * את מלבן החלטת הפקיד נציב מתחתיה במסך הראשי, לא בתוך הקומפוננטה הזו.
 */
function BudgetSidebar({ currentMonthBudget }) {
  if (!currentMonthBudget) {
    return (
      <section className="bg-white/80 rounded-lg p-4 border border-gov-border text-right text-gov-text-muted text-sm font-gov">
        אין נתוני תקציב לחודש זה.
      </section>
    );
  }

  return (
    <section className="bg-gov-blue-light/50 rounded-lg p-4 border-2 border-gov-blue/30 text-right shadow-sm font-gov">
      <h2 className="text-base font-bold text-gov-blue mb-3 border-b-2 border-gov-blue pb-2">
        תקציב החודש הנוכחי
      </h2>
      <ul className="space-y-2 text-sm">
        <li className="flex flex-col gap-0.5">
          <span className="text-gov-text-muted">סה״כ תקציב</span>
          <span className="font-bold text-gov-text text-lg">
            {formatMoney(currentMonthBudget.totalBudget)}
          </span>
        </li>
        <li className="flex flex-col gap-0.5">
          <span className="text-gov-text-muted">בשימוש</span>
          <span className="font-medium text-gov-text">
            {formatMoney(currentMonthBudget.usedBudget)}
          </span>
        </li>
        <li className="flex flex-col gap-0.5 border-t border-gov-border pt-2">
          <span className="text-gov-text-muted">זמין</span>
          <span className="font-bold text-gov-success text-lg">
            {formatMoney(currentMonthBudget.availableBudget)}
          </span>
        </li>
      </ul>
    </section>
  );
}

export default BudgetSidebar;
