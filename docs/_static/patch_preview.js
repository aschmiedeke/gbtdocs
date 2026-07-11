document.addEventListener("DOMContentLoaded", function() {
    // Create a standard, theme-safe popup div
    const popup = document.createElement("div");
    popup.style.position = "fixed";
    popup.style.display = "none";
    popup.style.background = "#fff";
    popup.style.color = "#333";
    popup.style.border = "1px solid #ccc";
    popup.style.padding = "12px";
    popup.style.borderRadius = "6px";
    popup.style.boxShadow = "0 4px 12px rgba(0,0,0,0.15)";
    popup.style.zIndex = "999999";
    popup.style.maxWidth = "300px";
    popup.style.fontFamily = "sans-serif";
    document.body.appendChild(popup);

    document.querySelectorAll("[data-link-preview]").forEach(link => {
        link.addEventListener("mouseenter", async (e) => {
            const url = new URL(link.href);
            // Fetch the preview data from the native RTD API directly
            const apiUrl = `/_/api/v3/embed/?url=${encodeURIComponent(url.href)}`;
            
            try {
                const res = await fetch(apiUrl);
                const data = await res.json();
                if (data.content) {
                    popup.innerHTML = data.content;
                    popup.style.display = "block";
                    popup.style.left = `${e.clientX + 15}px`;
                    popup.style.top = `${e.clientY + 15}px`;
                }
            } catch (err) { console.error(err); }
        });

        link.addEventListener("mouseleave", () => {
            popup.style.display = "none";
        });
    });
});
