// src/types/global.d.ts
import { RequestHeaders } from '../common/header-utils';

declare global {
    type RequestHeaders = RequestHeaders;
}