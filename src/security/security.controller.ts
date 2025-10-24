import { Body, Controller, Post, Req } from "@nestjs/common";
import { SecurityService } from "./security.service";
import type { SetPinDTO } from "./dto/set-pin.dto";


@Controller('security') 
export class SecurityController{
    constructor (private readonly securityService:SecurityService){}

  @Post('pin/set')
  async setpin(@Body()payload :SetPinDTO,@Req() request :any){
    try {
        await this.securityService.setpin(payload);
    } catch (error) {
        
    }
  }
}