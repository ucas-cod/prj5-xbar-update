package cod

import chisel3._
import chisel3.util._

trait HasEmuLog {
  def emulog_theme: String = "Default"

  private val timer = RegInit(0.U(64.W))
  timer := timer + 1.U

  def log_prefix = s"cycle: %d [$emulog_theme] "

  class RawEmuLogger {
    def log_raw(prefix: String, fmt: String, tail: String, args: Bits*) = {
      printf(prefix + fmt + tail, args:_*)
    }

    /** Log with nothing added */
    def emulog(fmt: String, args: Bits*) = log_raw(log_prefix, fmt, "\n", timer +: args:_*)
  }

  private val rawEmuLogger = new RawEmuLogger

  /** Single log */
  def emulog(fmt: String, args: Bits*) = rawEmuLogger.log_raw(log_prefix, fmt, "\n", timer +: args:_*)

  def emulog(en: Bool, fmt: String, args: Bits*): Unit = when (en) { emulog(fmt, args:_*) }
}