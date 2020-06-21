package cod

import chisel3._
import chisel3.util._

/**
 * Simple AXI4 Crossbar.
 * @param m Number of masters.
 * @param addressSpace Destination address spaces.
 */
class AXI4Xbar(m: Int, addressSpace: List[(Long, Long)]) extends Module with HasEmuLog {
  // Config emu log prefix
  override def emulog_theme = "axi4xbar"

  /**
   * IO ports definition
   */
  val io = IO(new Bundle {
    val in = Vec(m, Flipped(new AXI4))
    val out = Vec(addressSpace.size, new AXI4)
  })


  /**
   * Provided example to show iteration, when, and emulog debug print.
   */
  for ((in, i) <- io.in.zipWithIndex) {
    when (in.ar.valid) { emulog("in[%d] ar valid addr %x id %x", i.U, in.ar.bits.addr, in.ar.bits.id)}
    when (in.aw.valid) { emulog("in[%d] aw valid addr %x id %x", i.U, in.aw.bits.addr, in.aw.bits.id)}
    when (in.w.valid) { emulog("in[%d] w valid last %b", i.U, in.w.bits.last)}
  }

  for ((out, i) <- io.out.zipWithIndex) {
    when (out.r.valid) { emulog("out[%d] r valid id %x last %b", i.U, out.r.bits.id, out.r.bits.last)}
    when (out.b.valid) { emulog("out[%d] b valid id %x", i.U, out.b.bits.id) }
  }

  // How many bits we need in this xbar to add id
  val inIdBits = log2Ceil(io.in.size)
  // Compiling time log, show hardware info
  println(s"Xbar has ${io.in.size} masters and ${io.out.size} clients, additional id bits usage is $inIdBits")

  /**
   * Arbiter array
   *
   * Usage example:
   *   arbiter.io.in(i).valid := io.in(i).valid && some_enable
   *   io.in(i).ready := arbiter.io.in(i).ready && some_enable
   *   arbiter.io.in(i).bits := io.in(i).bits // AXI4 bundle
   *
   *   io.out(j) <> arbiters(j).io.out
   *
   *   arbiter.io.chosen  // THIS IS VERY IMMPORTANT, IT TELLS US WHICH IN PORT IS SELECTED!!!
   */
  val outARArbs = Seq.fill(addressSpace.size) { Module(new Arbiter(new AXI4BundleA(AXI4Parameters.dataBits), m)) }
  val outAWArbs = Seq.fill(addressSpace.size) { Module(new Arbiter(new AXI4BundleA(AXI4Parameters.dataBits), m)) }


  // Route AW, remeber to save out destination for W



  // Route W
  io.out.map(_.w).foreach(w => w <> 0.U.asTypeOf(w)) // Initialized for all addr cases.



  // Route B
  io.in.map(_.b) foreach (b => b <> 0.U.asTypeOf(b)) // Initialized for all addr cases.



  // Route AR



  // Route R
  io.in.map(_.r) foreach (r => r <> 0.U.asTypeOf(r)) // Initialized for all addr cases.




}
