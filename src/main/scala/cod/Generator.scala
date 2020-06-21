package cod

import chisel3._

object Generator extends App {
  Driver.execute(args, () => new AXI4Xbar(2, List((0x00000000L, 0x80100000L))))
}
