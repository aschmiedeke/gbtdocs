// Pre-inject the master Read the Docs addons container if it's missing
document.addEventListener("DOMContentLoaded", function () {
    if (!document.getElementsByTagName('readthedocs-addons').length) {
        const addonsContainer = document.createElement('readthedocs-addons');
        document.body.appendChild(addonsContainer);
        console.log("RTD Patch: Pre-injected <readthedocs-addons> container.");
    }
});
