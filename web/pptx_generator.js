async function generateProductPresentation(products, fileName) {
    try {
        if (!Array.isArray(products) || products.length === 0) {
            throw new Error("No products found for presentation.");
        }

        const pptx = new PptxGenJS();

        // ============================================================
        // PRESENTATION SETTINGS
        // ============================================================
        pptx.layout = "LAYOUT_WIDE";

        pptx.author = "Display Room";
        pptx.company = "Display Room";
        pptx.subject = "Selected Product Catalogue";
        pptx.title = "Display Room Product Presentation";
        pptx.lang = "en-US";

        pptx.theme = {
            headFontFace: "Aptos Display",
            bodyFontFace: "Aptos",
            lang: "en-US"
        };

        // ============================================================
        // COLORS
        // ============================================================
        const PRIMARY = "233876";
        const DARK = "182236";
        const TEXT = "293241";
        const MUTED = "6B7280";
        const LIGHT = "F4F6FA";
        const BORDER = "E4E8F0";
        const WHITE = "FFFFFF";

        // ============================================================
        // HELPER
        // ============================================================
        function clean(value) {
            if (value === null || value === undefined) {
                return "";
            }

            const text = String(value).trim();

            if (text.toLowerCase() === "null") {
                return "";
            }

            return text;
        }

        function addFooter(slide, index) {
            slide.addShape(pptx.ShapeType.line, {
                x: 0.55,
                y: 7.12,
                w: 12.2,
                h: 0,
                line: {
                    color: BORDER,
                    width: 1
                }
            });

            slide.addText("DISPLAY ROOM", {
                x: 0.6,
                y: 7.18,
                w: 2.5,
                h: 0.18,
                fontSize: 7,
                bold: true,
                color: MUTED,
                charSpacing: 1.2,
                margin: 0
            });

            slide.addText(String(index), {
                x: 11.8,
                y: 7.18,
                w: 0.8,
                h: 0.18,
                fontSize: 7,
                color: MUTED,
                align: "right",
                margin: 0
            });
        }

        function addInfoRow(slide, label, value, y) {
            value = clean(value);

            if (!value) {
                return y;
            }

            slide.addText(label.toUpperCase(), {
                x: 7.05,
                y: y,
                w: 1.7,
                h: 0.22,
                fontSize: 8,
                bold: true,
                color: MUTED,
                margin: 0
            });

            slide.addText(value, {
                x: 8.8,
                y: y - 0.02,
                w: 3.8,
                h: 0.3,
                fontSize: 11,
                bold: true,
                color: TEXT,
                margin: 0,
                breakLine: false
            });

            return y + 0.48;
        }

        // ============================================================
        // COVER SLIDE
        // ============================================================
        {
            const slide = pptx.addSlide();

            slide.background = {
                color: WHITE
            };

            slide.addShape(pptx.ShapeType.rect, {
                x: 0,
                y: 0,
                w: 4.6,
                h: 7.5,
                line: {
                    transparency: 100
                },
                fill: {
                    color: PRIMARY
                }
            });

            slide.addShape(pptx.ShapeType.rect, {
                x: 4.6,
                y: 0,
                w: 8.73,
                h: 7.5,
                line: {
                    transparency: 100
                },
                fill: {
                    color: WHITE
                }
            });

            slide.addText("DISPLAY\nROOM", {
                x: 0.65,
                y: 1.2,
                w: 3.4,
                h: 1.5,
                fontSize: 34,
                bold: true,
                color: WHITE,
                margin: 0,
                breakLine: false
            });

            slide.addText("PRODUCT SELECTION", {
                x: 0.68,
                y: 3.05,
                w: 3.2,
                h: 0.35,
                fontSize: 10,
                bold: true,
                color: "D7DFF7",
                charSpacing: 2,
                margin: 0
            });

            slide.addText(
                "A curated collection of selected products for your review.",
                {
                    x: 5.35,
                    y: 2.1,
                    w: 6.5,
                    h: 0.8,
                    fontSize: 27,
                    bold: true,
                    color: DARK,
                    margin: 0
                }
            );

            slide.addText(
                `${products.length} Selected Products`,
                {
                    x: 5.38,
                    y: 3.35,
                    w: 4,
                    h: 0.35,
                    fontSize: 13,
                    color: MUTED,
                    margin: 0
                }
            );

            const date = new Date();

            slide.addText(
                date.toLocaleDateString(),
                {
                    x: 5.38,
                    y: 3.85,
                    w: 3,
                    h: 0.3,
                    fontSize: 10,
                    color: MUTED,
                    margin: 0
                }
            );
        }

        // ============================================================
        // PRODUCT SLIDES
        // ============================================================
        for (let i = 0; i < products.length; i++) {
            const product = products[i];

            const slide = pptx.addSlide();

            slide.background = {
                color: WHITE
            };

            // --------------------------------------------------------
            // TOP LABEL
            // --------------------------------------------------------
            slide.addText(
                `PRODUCT ${String(i + 1).padStart(2, "0")}`,
                {
                    x: 0.65,
                    y: 0.42,
                    w: 2,
                    h: 0.25,
                    fontSize: 8,
                    bold: true,
                    color: PRIMARY,
                    charSpacing: 1.2,
                    margin: 0
                }
            );

            // --------------------------------------------------------
            // PRODUCT TITLE
            // --------------------------------------------------------
            const title =
                clean(product.description) ||
                clean(product.itemName) ||
                clean(product.itemCode) ||
                `Product ${i + 1}`;

            slide.addText(title, {
                x: 0.65,
                y: 0.78,
                w: 11.9,
                h: 0.7,
                fontSize: 22,
                bold: true,
                color: DARK,
                margin: 0,
                breakLine: false
            });

            // --------------------------------------------------------
            // IMAGE BACKGROUND
            // --------------------------------------------------------
            slide.addShape(pptx.ShapeType.roundRect, {
                x: 0.65,
                y: 1.7,
                w: 5.75,
                h: 4.85,
                rectRadius: 0.08,
                line: {
                    color: BORDER,
                    width: 1
                },
                fill: {
                    color: LIGHT
                }
            });

            // --------------------------------------------------------
            // PRODUCT IMAGE
            // --------------------------------------------------------
            const imageUrl = clean(product.imageUrl);

            if (imageUrl) {
                try {
                    slide.addImage({
                        path: imageUrl,
                        x: 0.95,
                        y: 2.0,
                        w: 5.15,
                        h: 4.25,
                        transparency: 0
                    });
                } catch (e) {
                    console.warn("Could not add image:", imageUrl, e);

                    slide.addText("PRODUCT IMAGE", {
                        x: 1.2,
                        y: 3.7,
                        w: 4.6,
                        h: 0.4,
                        fontSize: 12,
                        bold: true,
                        color: MUTED,
                        align: "center"
                    });
                }
            } else {
                slide.addText("PRODUCT IMAGE", {
                    x: 1.2,
                    y: 3.7,
                    w: 4.6,
                    h: 0.4,
                    fontSize: 12,
                    bold: true,
                    color: MUTED,
                    align: "center"
                });
            }

            // --------------------------------------------------------
            // QUANTITY BADGE
            // --------------------------------------------------------
            slide.addShape(pptx.ShapeType.roundRect, {
                x: 10.75,
                y: 1.72,
                w: 1.75,
                h: 0.55,
                rectRadius: 0.08,
                line: {
                    transparency: 100
                },
                fill: {
                    color: PRIMARY
                }
            });

            slide.addText(
                `QTY  ${clean(product.quantity) || "1"}`,
                {
                    x: 10.88,
                    y: 1.88,
                    w: 1.48,
                    h: 0.2,
                    fontSize: 9,
                    bold: true,
                    color: WHITE,
                    align: "center",
                    margin: 0
                }
            );

            // --------------------------------------------------------
            // DETAILS
            // --------------------------------------------------------
            let y = 2.55;

            y = addInfoRow(
                slide,
                "Item Code",
                product.itemCode,
                y
            );

            y = addInfoRow(
                slide,
                "Business",
                product.business,
                y
            );

            y = addInfoRow(
                slide,
                "Category",
                product.category,
                y
            );

            y = addInfoRow(
                slide,
                "Sub Category",
                product.subCategory,
                y
            );

            y = addInfoRow(
                slide,
                "Color",
                product.color,
                y
            );

            y = addInfoRow(
                slide,
                "UOM",
                product.uom,
                y
            );

            y = addInfoRow(
                slide,
                "Unit Price",
                product.unitPrice,
                y
            );

            addFooter(slide, i + 1);
        }

        // ============================================================
        // THANK YOU SLIDE
        // ============================================================
        {
            const slide = pptx.addSlide();

            slide.background = {
                color: PRIMARY
            };

            slide.addText(
                "Thank You",
                {
                    x: 1,
                    y: 2.35,
                    w: 11.3,
                    h: 0.75,
                    fontSize: 38,
                    bold: true,
                    color: WHITE,
                    align: "center",
                    margin: 0
                }
            );

            slide.addText(
                "We look forward to working with you.",
                {
                    x: 1.4,
                    y: 3.35,
                    w: 10.5,
                    h: 0.4,
                    fontSize: 15,
                    color: "DDE4F8",
                    align: "center",
                    margin: 0
                }
            );
        }

        // ============================================================
        // DOWNLOAD PPTX
        // ============================================================
        await pptx.writeFile({
            fileName: fileName,
            compression: true
        });

        return true;
    } catch (error) {
        console.error("PPTX generation error:", error);

        throw error;
    }
}

// Flutter/Dart যেন global function হিসেবে পায়
window.generateProductPresentation =
    generateProductPresentation;