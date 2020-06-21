package cod

/**
 * Obtained from NOOP project, originated by yuzihao.
 */

import chisel3._
import chisel3.util._

object AXI4Parameters {
  // These are all fixed by the AXI4 standard:
  val lenBits   = 8
  val sizeBits  = 3
  val burstBits = 2
  val cacheBits = 4
  val protBits  = 3
  val qosBits   = 4
  val respBits  = 2

  // These are not fixed:
  val idBits    = 10
  val addrBits  = 32
  val dataBits  = 32
  val userBits  = 1

  def CACHE_RALLOCATE  = 8.U(cacheBits.W)
  def CACHE_WALLOCATE  = 4.U(cacheBits.W)
  def CACHE_MODIFIABLE = 2.U(cacheBits.W)
  def CACHE_BUFFERABLE = 1.U(cacheBits.W)

  def PROT_PRIVILEDGED = 1.U(protBits.W)
  def PROT_INSECURE    = 2.U(protBits.W)
  def PROT_INSTRUCTION = 4.U(protBits.W)

  def BURST_FIXED = 0.U(burstBits.W)
  def BURST_INCR  = 1.U(burstBits.W)
  def BURST_WRAP  = 2.U(burstBits.W)

  def RESP_OKAY   = 0.U(respBits.W)
  def RESP_EXOKAY = 1.U(respBits.W)
  def RESP_SLVERR = 2.U(respBits.W)
  def RESP_DECERR = 3.U(respBits.W)
}

trait AXI4HasUser {
  val user  = UInt(AXI4Parameters.userBits.W)
}

trait AXI4HasData {
  def dataBits = AXI4Parameters.dataBits
  val data  = UInt(dataBits.W)
}

trait AXI4HasId {
  def idBits = AXI4Parameters.idBits
  val id    = UInt(idBits.W)
}

trait AXI4HasLast {
  val last = Bool()
}

// AXI4-lite

class AXI4LiteBundleA extends Bundle {
  val addr  = UInt(AXI4Parameters.addrBits.W)
  val prot  = UInt(AXI4Parameters.protBits.W)
}

class AXI4LiteBundleW(override val dataBits: Int = AXI4Parameters.dataBits) extends Bundle with AXI4HasData {
  val strb = UInt((dataBits/8).W)
}

class AXI4LiteBundleB extends Bundle {
  val resp = UInt(AXI4Parameters.respBits.W)
}

class AXI4LiteBundleR(override val dataBits: Int = AXI4Parameters.dataBits) extends AXI4LiteBundleB with AXI4HasData

class AXI4Lite extends Bundle {
  val aw = Decoupled(new AXI4LiteBundleA)
  val w  = Decoupled(new AXI4LiteBundleW)
  val b  = Flipped(Decoupled(new AXI4LiteBundleB))
  val ar = Decoupled(new AXI4LiteBundleA)
  val r  = Flipped(Decoupled(new AXI4LiteBundleR))
}


// AXI4

class AXI4BundleA(override val idBits: Int) extends AXI4LiteBundleA with AXI4HasId with AXI4HasUser {
  val len   = UInt(AXI4Parameters.lenBits.W)  // number of beats - 1
  val size  = UInt(AXI4Parameters.sizeBits.W) // bytes in beat = 2^size
  val burst = UInt(AXI4Parameters.burstBits.W)
  val lock  = Bool()
  val cache = UInt(AXI4Parameters.cacheBits.W)
  val qos   = UInt(AXI4Parameters.qosBits.W)  // 0=no QoS, bigger = higher priority
  // val region = UInt(width = 4) // optional
}

// id ... removed in AXI4
class AXI4BundleW(override val dataBits: Int) extends AXI4LiteBundleW(dataBits) with AXI4HasLast
class AXI4BundleB(override val idBits: Int) extends AXI4LiteBundleB with AXI4HasId with AXI4HasUser
class AXI4BundleR(override val dataBits: Int, override val idBits: Int) extends AXI4LiteBundleR(dataBits) with AXI4HasLast with AXI4HasId with AXI4HasUser


class AXI4(val dataBits: Int = AXI4Parameters.dataBits, val idBits: Int = AXI4Parameters.idBits) extends AXI4Lite {
  override val aw = Decoupled(new AXI4BundleA(idBits))
  override val w  = Decoupled(new AXI4BundleW(dataBits))
  override val b  = Flipped(Decoupled(new AXI4BundleB(idBits)))
  override val ar = Decoupled(new AXI4BundleA(idBits))
  override val r  = Flipped(Decoupled(new AXI4BundleR(dataBits, idBits)))
}