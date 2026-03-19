import React from 'react';
import { formatMoney } from './formatters';

/**
 * מלבן – החלטת הפקיד: סכום לאישור, כפתורי אשר/דחה.
 */
function ClerkDecisionCard({
  currentRequest,
  approvedAmount,
  onApprovedAmountChange,
  onApprove,
  onReject,
  onCalculate,
  calculateLoading,
  calculateError,
  loading,
  success,
  successType,
  error,
}) {
  const hasCalculatedAmount = currentRequest?.calculatedAmount != null;

  return (
    <section className="bg-white rounded p-4 border-2 border-gov-blue/40">
      <h2 className="text-lg font-bold text-gov-blue mb-3 border-b-2 border-gov-blue pb-2 font-gov">אישור סכום ההחזר</h2>
      {hasCalculatedAmount ? (
        <p className="text-sm text-gov-text-muted mb-2 font-gov">
          סכום מחושב מוצע: {formatMoney(currentRequest.calculatedAmount)}
        </p>
      ) : (
        <div className="mb-2">
          <button
            type="button"
            onClick={onCalculate}
            disabled={calculateLoading}
            className="px-3 py-2 text-sm rounded bg-gov-blue text-white font-semibold hover:bg-gov-blue-dark disabled:opacity-70 disabled:cursor-not-allowed font-gov transition"
          >
            {calculateLoading ? 'מחשב...' : 'חשב סכום החזר'}
          </button>
          {calculateError && <p className="text-sm text-gov-error mt-2 font-gov">{calculateError}</p>}
        </div>
      )}
      <div className="flex flex-col gap-2 max-w-xs">
        <label htmlFor="approvedAmount" className="text-sm font-medium text-gov-text font-gov">
          סכום לאישור (₪)
        </label>
        <input
          id="approvedAmount"
          type="text"
          inputMode="decimal"
          placeholder="0.00"
          value={approvedAmount}
          onChange={(e) => onApprovedAmountChange(e.target.value)}
          className="px-3 py-2 border border-gov-border rounded text-right font-medium font-gov focus:border-gov-blue focus:ring-2 focus:ring-gov-blue/20 outline-none"
          dir="ltr"
          disabled={loading || success}
        />
      </div>
      {error && <p className="mt-2 text-sm text-gov-error font-gov">{error}</p>}
      {success && (
        <p className={`mt-2 text-sm font-medium font-gov ${successType === 'rejected' ? 'text-gov-error' : 'text-gov-success'}`}>
          {successType === 'rejected' ? 'הבקשה נדחתה. מחזיר לרשימה...' : 'הבקשה אושרה. מחזיר לרשימה...'}
        </p>
      )}
      <div className="flex gap-2 mt-3">
        <button
          type="button"
          onClick={onApprove}
          disabled={loading || success}
          className="px-4 py-2 text-sm rounded bg-gov-success text-white font-semibold hover:bg-gov-success-dark disabled:opacity-50 disabled:cursor-not-allowed font-gov transition"
        >
          {loading ? 'שולח...' : 'אשר החזר'}
        </button>
        <button
          type="button"
          onClick={onReject}
          disabled={loading || success}
          className="px-4 py-2 text-sm rounded border border-gov-error bg-white text-gov-error font-semibold hover:bg-gov-error hover:text-white disabled:opacity-50 disabled:cursor-not-allowed font-gov transition"
        >
          {loading ? 'שולח...' : 'דחה בקשה'}
        </button>
      </div>
    </section>
  );
}

export default ClerkDecisionCard;
