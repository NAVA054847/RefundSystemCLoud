using Microsoft.AspNetCore.Mvc;
using RefundSystem.API.Dtos;
using RefundSystem.Core.Interfaces;
using RefundSystem.Core.ReadModels;

namespace RefundSystem.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class RefundController : ControllerBase
    {
        private readonly IRefundService _service;

        public RefundController(IRefundService service)
        {
            _service = service;
        }

        // יצירת בקשת החזר
        [HttpPost]
        public async Task<IActionResult> Create(
            [FromBody] CreateRefundRequestDto dto,
            CancellationToken cancellationToken)
        {
            await _service.CreateRefundRequestAsync(
                dto.CitizenId,
                dto.TaxYear,
                cancellationToken);

            return Ok();
        }

        // חישוב זכאות
        [HttpPost("{requestId}/calculate")]
        public async Task<IActionResult> Calculate(
            int requestId,
            CancellationToken cancellationToken)
        {
            await _service.CalculateRefundAsync(
                requestId,
                cancellationToken);

            return Ok();
        }

        // רשימת בקשות שמחכות לפקיד
        [HttpGet("pending")]
        public async Task<ActionResult<IReadOnlyList<PendingRequestReadModel>>> GetPending(
            CancellationToken cancellationToken)
        {
            var result = await _service
                .GetPendingRequestsForClerkAsync(cancellationToken);

            return Ok(result);
        }

        // פרטי בקשה לפקיד
        [HttpGet("{requestId}")]
        public async Task<ActionResult<ClerkRequestDetailsReadModel>> GetDetails(
            int requestId,
            CancellationToken cancellationToken)
        {
            var result = await _service
                .GetRequestDetailsForClerkAsync(requestId, cancellationToken);

            if (result == null)
                return NotFound();

            return Ok(result);
        }

        // תצוגת אזרח: בקשה אחרונה + היסטוריה (לפי ת.ז.)
        [HttpGet("citizen/{identityNumber}")]
        public async Task<ActionResult<CitizenRequestViewReadModel>> GetCitizenView(
            string identityNumber,
            CancellationToken cancellationToken)
        {
            var result = await _service
                .GetCitizenRequestViewAsync(identityNumber, cancellationToken);

            if (result == null)
                return NotFound();

            return Ok(result);
        }

        // אישור / דחייה
        [HttpPost("approve")]
        public async Task<IActionResult> ApproveOrReject(
            [FromBody] ApproveRefundRequestDto dto,
            CancellationToken cancellationToken)
        {
            await _service.ApproveOrRejectRefundRequestAsync(
                dto.RequestId,
                dto.IsApproved,
                dto.ApprovedAmount,
                cancellationToken);

            return Ok();
        }
    }
}