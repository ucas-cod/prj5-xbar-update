package cod

import chisel3._
import chisel3.util._
import chisel3.iotesters._


class AXI4Master(name: String, id: Int, reqs: Seq[Req]) extends Module with HasEmuLog {
  val io = IO(new Bundle {
    val axi = new AXI4
    val success = Output(Bool())
  })

  val axi = io.axi

  override def emulog_theme = "master_" + name

  val s_idle :: s_aw :: s_w :: s_bresp :: s_ar :: s_r :: s_end :: Nil = Enum(7)
  val state = RegInit(s_idle)

  io.success := state === s_end

  axi.ar.valid := false.B
  axi.ar.bits := 0.U.asTypeOf(axi.ar.bits)
  axi.r.ready := false.B

  axi.aw.valid := false.B
  axi.aw.bits := 0.U.asTypeOf(axi.aw.bits)
  axi.w.valid := false.B
  axi.w.bits := 0.U.asTypeOf(axi.w.bits)
  axi.b.ready := false.B

  val (w_cnt, w_last) = Counter(axi.w.fire(), 1)

  when (state =/= s_idle) {
    emulog("state = %d", state)
  }

  val addrs = reqs.map(_.address)
  val req_no = Counter(reqs.size)
  val req_rw = VecInit(reqs.map(_.rw.U))
  val req_addr = VecInit(addrs.map(_.U))
  val beats = VecInit(reqs.map(_.beats.U - 1.U))

  switch (state) {
    is (s_idle) {
      when (req_rw(req_no.value) === 0.U) {
        state := s_ar
      }.elsewhen (req_rw(req_no.value) === 1.U) {
        state := s_aw
      }
    }

    is (s_aw) {
      axi.aw.valid := true.B
      axi.aw.bits.addr := req_addr(req_no.value)
      axi.aw.bits.id := id.U
      axi.aw.bits.len := beats(req_no.value)

      when (axi.aw.fire()) {
        emulog("aw fired")
        state := s_w
      }

      axi.w.valid := true.B
      axi.w.bits.last := w_last
      when (axi.w.fire()) {
        emulog("w fire cnt %d", w_cnt)
      }
      when (axi.w.fire() && w_last) {
        emulog("w last")
        state := s_bresp
      }
    }

    is (s_w) {
      axi.w.valid := true.B
      axi.w.bits.last := w_last
      when (axi.w.fire()) {
        emulog("w fire cnt %d", w_cnt)
      }
      when (axi.w.fire() && w_last) {
        emulog("w last")
        state := s_bresp
      }
    }

    is (s_bresp) {
      axi.b.ready := true.B
      when (axi.b.fire()) {
        emulog("bresp fired, id %x", axi.b.bits.id)
        req_no.inc()
        when (req_no.value === (reqs.size - 1).U) {
          state := s_end
        }.otherwise {
          state := s_idle
        }
      }
    }

    is (s_ar) {
      axi.ar.valid := true.B
      axi.ar.bits.addr := req_addr(req_no.value)
      axi.ar.bits.id := id.U
      axi.ar.bits.len := beats(req_no.value)
      when (axi.ar.fire()) {
        emulog("ar fired")
        state := s_r
      }
    }

    is (s_r) {
      axi.r.ready := true.B
      when (axi.r.fire()) {
        emulog("r fired, id %x", axi.r.bits.id)
        when (axi.r.bits.last) {
          emulog("r last")
          req_no.inc()
          when (req_no.value === (reqs.size - 1).U) {
            state := s_end
          }.otherwise {
            state := s_idle
          }
        }
      }
    }
  }
}


class AXI4Client(name: String) extends Module with HasEmuLog {
  val io = IO(Flipped(new AXI4))

  override def emulog_theme = "client_" + name

  val s_idle :: s_aw :: s_w :: s_bresp :: s_ar :: s_r :: s_end :: Nil = Enum(7)
  val state = RegInit(s_idle)
  val id = RegInit(0.U(AXI4Parameters.idBits.W))

  io.r.bits := 0.U.asTypeOf(io.r.bits)
  io.b.bits := 0.U.asTypeOf(io.b.bits)

  io.ar.ready := false.B
  io.r.valid := false.B

  io.aw.ready := false.B
  io.w.ready := false.B
  io.b.valid := false.B

  when (state =/= s_idle) {
    emulog("state = %d", state)
  }

  val (r_cnt, r_last) = Counter(io.r.fire(), 4)

  switch (state) {
    is (s_idle) {
      io.ar.ready := true.B
      when (io.ar.fire()) {
        emulog("ar fired, addr %x, id %x", io.ar.bits.addr, io.ar.bits.id)
        id := io.ar.bits.id
        state := s_r
      }

      io.aw.ready := true.B
      when (io.aw.fire()) {
        emulog("aw fired addr %x id %x", io.aw.bits.addr, io.aw.bits.id)
        id := io.aw.bits.id
        state := s_w
      }

      io.w.ready := true.B
      when (io.w.fire()) {
        emulog("w fired")
        when (io.w.bits.last) {
          emulog("w last")
          state := s_bresp
        }
      }
    }

    is (s_w) {
      io.w.ready := true.B
      when (io.w.fire()) {
        emulog("w fired")
        when (io.w.bits.last) {
          emulog("w last")
          state := s_bresp
        }
      }
    }

    is (s_bresp) {
      io.b.valid := true.B
      io.b.bits.id := id
      when (io.b.fire()) {
        emulog("bresp fired")
        state := s_idle
      }
    }

    is (s_r) {
      io.r.valid := true.B
      io.r.bits.id := id
      io.r.bits.last := r_last
      when (io.r.fire()) {
        emulog("r fired %d", r_cnt)
        when (r_last) {
          emulog("r last")
          state := s_idle
        }
      }
    }
  }
}

case class Req(rw: Int, address: BigInt, beats: Int)
case class MasterParam(name: String, reqs: Req*)

class Testharness(masterPrams: Seq[MasterParam], addressSpaces: List[(Long, Long)]) extends Module {
  val io = IO(new Bundle {
    val success = Output(Bool())
  })

  val xbr = Module(new AXI4Xbar(masterPrams.size, addressSpaces))

  val slaves = addressSpaces.zipWithIndex.map { case ((start, end), i) =>
    Module(new AXI4Client(s"C${i+1}"))
  }

  val masters = masterPrams.zipWithIndex.map { case (master, i) =>
    Module(new AXI4Master(master.name, i + 1, master.reqs))
  }

  for ((in, m) <- (xbr.io.in zip masters)) {
    in <> m.io.axi
  }

  for ((out, s) <- (xbr.io.out zip slaves)) {
    s.io <> out
  }

  io.success := masters.map(_.io.success).reduce(_&&_)
}

class AXI4XbarTester(c: Testharness) extends PeekPokeTester(c) {
  var flag = true
  var cycles = 1
  while (flag && cycles < 1000) {
    println("==================================")
    step(1)
    if (peek(c.io.success) == 1) {
      println(s"Success in about ${cycles} cycles")
      flag = false
    }
    cycles += 1
  }
  if (flag) {
    println(s"Failed due to cycle expires (${cycles}), check xbar implementation or test scale")
    fail
  }
}

object Test extends App {
  val addressSpaces = List((0x1000L, 0x2000L), (0x2000L, 0x3000L), (0x3000L, 0x4000L))
  val R = 0
  val W = 1
  val masterSets = List(
    List(
      MasterParam("A", Req(W, 0x1100, 4), Req(W, 0x2100, 4), Req(W, 0x3100, 1)),
      MasterParam("B", Req(W, 0x1200, 2), Req(W, 0x1300, 4), Req(W, 0x3100, 1))),
    List(
      MasterParam("A", Req(W, 0x1100, 4), Req(W, 0x2100, 4), Req(W, 0x3100, 1)),
      MasterParam("B", Req(R, 0x1100, 2), Req(R, 0x2200, 4), Req(R, 0x3200, 1)))
  )

  masterSets foreach { masterSet =>
    println(">>>>> test set start <<<<<<<")
    chisel3.iotesters.Driver(() => new Testharness(masterSet, addressSpaces)) { c =>
      new AXI4XbarTester(c)
    }
    println("<<<<< test set ended >>>>>>>")
  }
}