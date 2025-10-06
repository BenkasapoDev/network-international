import { BadRequestException } from '@nestjs/common';

export interface RequestHeaders {
    requestId: string;
    correlationId: string;
    orgId: string;
    timestamp: Date;
    srcApp: string;
    channel: string;
}

export function extractAndValidateHeaders(headers: any): RequestHeaders {
    const requestId = headers['x-request-id'];
    if (!requestId || requestId.length > 12) {
        throw new BadRequestException('X-Request-ID is required and must be <= 12 characters');
    }

    const correlationId = headers['x-correlation-id'];
    if (!correlationId || correlationId.length > 12) {
        throw new BadRequestException('X-Correlation-ID is required and must be <= 12 characters');
    }

    const orgId = headers['x-orgid'];
    if (!orgId) {
        throw new BadRequestException('X-OrgId is required');
    }

    const timestampStr = headers['x-timestamp'];
    let timestamp: Date;
    if (!timestampStr) {
        timestamp = new Date();
    } else {
        // Validate YYYY-MM-DD format
        const dateRegex = /^\d{4}-\d{2}-\d{2}$/;
        if (!dateRegex.test(timestampStr)) {
            throw new BadRequestException('X-Timestamp must be in YYYY-MM-DD format (e.g., 2023-07-24)');
        }
        try {
            timestamp = new Date(timestampStr);
        } catch {
            throw new BadRequestException('X-Timestamp must be a valid date in YYYY-MM-DD format');
        }
    }

    const srcApp = headers['x-srcapp'] || 'client'; // Default to 'client'
    const channel = headers['x-channel'] || 'Bank'; // Default to 'Bank'

    return {
        requestId,
        correlationId,
        orgId,
        timestamp,
        srcApp,
        channel,
    };
}