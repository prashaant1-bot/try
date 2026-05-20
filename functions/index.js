const {onRequest} = require("firebase-functions/v2/https");

exports.evaluateEssay = onRequest(
    {secrets: ["OPENAI_API_KEY"]},
    async (req, res) => {
      try {
        const body = req.body;

        const response = await fetch(
            "https://api.openai.com/v1/chat/completions",
            {
              method: "POST",
              headers: {
                "Content-Type": "application/json",
                "Authorization":
                            `Bearer ${process.env.OPENAI_API_KEY}`,
              },
              body: JSON.stringify(body),
            },
        );

        const data = await response.json();

        res.status(200).send(data);
      } catch (e) {
        console.log(e);

        res.status(500).send({
          error: e.toString(),
        });
      }
    },
);
