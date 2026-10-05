import QRCode from "qrcode";

/** Returns an inline SVG string for the given text. */
export async function qrSvg(text: string, color = "#000000"): Promise<string> {
  return QRCode.toString(text, {
    type: "svg",
    margin: 0,
    errorCorrectionLevel: "M",
    color: { dark: color, light: "#0000" },
  });
}
