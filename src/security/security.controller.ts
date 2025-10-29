import { Body, Controller, Post, Req } from "@nestjs/common";
import { SecurityService } from "./security.service";
import type { SetPinDTO } from "./dto/set-pin.dto";
import { RequestHeaders } from "src/common/header-utils";


@Controller('security')
export class SecurityController {
  constructor(private readonly securityService: SecurityService) { }

  @Post('pin/set')
  async setpin(@Body() payload: SetPinDTO, @Req() request: any) {
    // Extract validated headers from request
    const headers: RequestHeaders = request.validatedHeaders;

    if (!headers) {
      throw new Error('Headers not validated by interceptor');
    }

    try {
      // Call the service method with payload and headers
      return await this.securityService.setpin(payload, headers);
    } catch (error) {
      console.log('Error in SecurityController.setpin:', error);
      //throw new Error(`Failed to set PIN: ${error?.message|| 'Unknown error'}`);
    }
  }
}