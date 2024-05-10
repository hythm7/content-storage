document.addEventListener("DOMContentLoaded",(function(){const e=document.getElementById("buildModal"),t=e.querySelector(".modal-body"),n=new EventSource("/distribution/build");var d=document.getElementById("drop-area"),r=document.getElementById("file-input");["dragenter","dragover","dragleave","drop"].forEach((function(e){d.addEventListener(e,(function(e){e.preventDefault(),e.stopPropagation()}))})),["dragenter","dragover"].forEach((function(e){d.addEventListener(e,(function(){d.classList.add("highlight")}))})),["dragleave","drop"].forEach((function(e){d.addEventListener(e,(function(){d.classList.remove("highlight")}))})),d.addEventListener("drop",(function(e){e.preventDefault(),e.stopPropagation();var t=e.dataTransfer.files;r.files=t,o(t)}));var a=document.getElementById("submit-button");function o(e){var t=document.querySelector(".form-label");e.length>0?(e=[...e],t.innerText="",e.forEach((e=>{t.innerText+=e.name+"\n"})),a.classList.remove("disabled")):(t.innerText="Drag and drop your distribution here or click to select a file.",a.classList.add("disabled"))}a.addEventListener("click",(function(){var e=r.files;console.log(e);for(var t=new FormData,n=0;n<e.length;n++)t.append("file-input",e[n]);fetch("/distribution/add",{method:"POST",body:t}).then((e=>e.json())).then((e=>{console.log("Processing:",e)})).catch((e=>{console.error("Error Processing:",e)}))})),r.addEventListener("change",(function(e){o(r.files)})),n.onerror=e=>{console.error("EventSource failed:",e)},n.addEventListener("message",(e=>{var t,n,d,r,a=JSON.parse(e.data);"BUILD"==a.target&&"ADD"==a.operation&&(console.log("BUILD ADD"),t=a.build,d=(n=document.getElementById("distributions-builds-table").getElementsByTagName("tbody")[0]).innerHTML,r='<tr data-bs-toggle="modal" data-bs-target="#buildModal" data-build-id="'+t.id+'">',r+="<td>"+t.status+"</td>",r+="<td>"+t.username+"</td>",r+="<td>"+t.filename+"</td>",r+="</tr>",n.innerHTML=r+d)}));var i=function(e){const n=document.createElement("li");n.textContent=e.data,t.appendChild(n)};e.addEventListener("show.bs.modal",(e=>{var t=e.relatedTarget.getAttribute("data-build-id");n.addEventListener(t,i,!1)})),e.addEventListener("hidden.bs.modal",(t=>{var d=e.getAttribute("data-build-id");n.removeEventListener(d,i,!1),e.querySelector(".modal-body").innerHTML=""}))}));