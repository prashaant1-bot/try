const { onCall } = require("firebase-functions/v2/https");
const OpenAI = require("openai");

exports.evaluateEssay = onCall(
    {
        timeoutSeconds: 540,
        memory: "1GiB",
        secrets: ["OPENAI_API_KEY"],
    },
    async (request) => {
        try {
            const client = new OpenAI({
                apiKey: process.env.OPENAI_API_KEY,
            });

            const data = request.data;

            const response =
                await client.chat.completions.create({
                    model: "gpt-4o",
                    messages: data.messages,
                    max_tokens: 2500,
                });

            return {
                success: true,
                result:
                    response.choices[0].message.content,
            };
        } catch (e) {
            console.error(e);

            return {
                success: false,
                error: e.toString(),
            };
        }
    }
);