import "dotenv/config"
import express from "express"
import cors from "cors"
import multer from "multer"
import vision from "@google-cloud/vision"


const app = express();

const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 10 * 1024 * 1024 // 10 MB
  }
});

app.use(cors());

app.use(express.json({ limit: "20kb" }));

app.use((req, res, next) => {
  console.log("REQ:", req.method, req.url);
  next();
});

app.get("/", (req, res) => {
  res.send("API is running");
});

let options;

const raw = process.env.GOOGLE_SERVICE_ACCOUNT_JSON;

if (raw && raw.trim().startsWith("{")) {
  options = { credentials: JSON.parse(raw) };
}

const client = new vision.ImageAnnotatorClient(options);

app.post("/api/label", upload.single("image"), async (req, res) => {
    try {
        if (!req.file) {
            return res.status(400).json(
                {
                    success: false,
                    message: "No image file recieved"
                }
            )
        }
        console.log("File recieved")

        const imageBuffer = req.file.buffer

        const [result] = await client.labelDetection({image: { content: imageBuffer }})
        const labels = result.labelAnnotations?.map(label => label.description).filter(Boolean) ?? []
        console.log(labels)
        return res.json(
            {
                success: true,
                message: "Image upload successfully",
                labels: labels
            }
        )
    } catch (error) {
        console.log("Upload route error", error)

        return res.status(500).json(
            {
                success: false,
                message: "Server Error"
            }
        )
    }
})

export default app;