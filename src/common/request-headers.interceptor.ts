import { Injectable, NestInterceptor, ExecutionContext, CallHandler } from '@nestjs/common';
import { Observable } from 'rxjs';
import { extractAndValidateHeaders } from './header-utils';

@Injectable()
export class RequestHeadersInterceptor implements NestInterceptor {
    intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
        const request = context.switchToHttp().getRequest();
        const headers = request.headers;

        try {
            const validatedHeaders = extractAndValidateHeaders(headers);
            // Attach to request for services to access
            request.validatedHeaders = validatedHeaders;
        } catch (error) {
            // Let the error propagate to be handled by exception filters
            throw error;
        }

        return next.handle();
    }
}