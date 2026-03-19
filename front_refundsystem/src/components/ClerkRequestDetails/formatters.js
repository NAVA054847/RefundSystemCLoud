export const MONTH_NAMES = ['', 'ינואר', 'פברואר', 'מרץ', 'אפריל', 'מאי', 'יוני', 'יולי', 'אוגוסט', 'ספטמבר', 'אוקטובר', 'נובמבר', 'דצמבר'];

export function formatDate(dateStr) {
  if (!dateStr) return '—';
  return new Date(dateStr).toLocaleDateString('he-IL', { year: 'numeric', month: '2-digit', day: '2-digit' });
}

export function formatMoney(num) {
  if (num == null) return '—';
  return `₪${Number(num).toLocaleString('he-IL')}`;
}
