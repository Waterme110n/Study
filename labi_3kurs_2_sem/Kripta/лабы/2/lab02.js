let fs=require("fs");

let sorabtxt=fs.readFileSync("sorab.txt");
let mongtxt=fs.readFileSync("mong.txt");
let binarytxt=fs.readFileSync("binary.txt");

let sorab = "AaBbCcČčĆćDdDžžÐđEeFfGgHhIiJjKkLlLjljMmNnNjnjOoPpRrSsŠšTtUuVvZzŽž";
let mong = "АаБбВвГгДдЕеЁёЖжЗзИиЙйКкЛлМмНнОоӨөПпРрСсТтУуҮүФфХхЦцЧчШшЩщЪъЫыЬьЭэЮюЯя";
let binary="01";

let shanon = (txt, alph) => {
    let H = 0;
    let sum = 0;
    for (let i = 0; i < alph.length; i++) {
        let letter = alph.charAt(i),
        regExp = new RegExp(letter, 'g');
        if (txt.match(regExp) === null) {
            p=0;
        } 
        else {
            p=txt.match(regExp).length / txt.length;
        } 
        //console.log(`{letter: '${letter}', P(${letter}) = ${p}}`);
        if (p !== 0) {
            H += p * Math.log2(p);
        }
        sum += p;
    }
    //console.log(`Sum of p: ${sum}`);
    return -H;
};
console.log("Задание 1:");
console.log(`Энтропия сорабского: ${shanon(sorabtxt.toString(), sorab)}`);
console.log(`Энтропия монгольского: ${shanon(mongtxt.toString(), mong)}`);

console.log("Задание 2:");
console.log(`Энтропия бинарного: ${shanon(binarytxt.toString(),binary)}`);

console.log("Задание 3:");
let FIOslav="Осадчий Павел Андреевич";
console.log(`Количество информации (Монгольский): ${FIOslav.length*shanon(FIOslav,mong)}`);

let convbinary=(txt)=>{
    let str;
    for (let i=0; i<txt.length; i++){
        str+=txt[i].charCodeAt(0).toString(2);
    }
    return str;
}

console.log(`Количество информации (бинарный): ${convbinary(FIOslav).length*shanon(convbinary(FIOslav),binary)}`);

let FIOcroa="Osadčy Pawel Andrej";

console.log(`Количество информации (Сорабский): ${FIOcroa.length*shanon(FIOcroa,sorab)}`);
console.log(`Количество информации (бинарный): ${convbinary(FIOcroa).length*shanon(convbinary(FIOcroa),binary)}`);

let condEntropy=(p)=>{
    let q=1-p;
    let H=(-p*Math.log2(p)-q*Math.log2(q));
    return H;
}

let countInfBinMist=(p,txt)=>{
    let count=(1-condEntropy(p))*convbinary(txt).length;
    return count;
}
console.log("Задание 4: ");
console.log(`ФИО в монгольском языке если p=0.1: ${countInfBinMist(0.1,FIOslav)}`);
console.log(`ФИО в монгольском языке если и p=0.5: ${countInfBinMist(0.5,FIOslav)}`);
console.log(`ФИО в монгольском языке если p=1: ${countInfBinMist(0.99999999999,FIOslav)}`);

console.log(`ФИО в сорабском языке если p=0.1: ${countInfBinMist(0.1,FIOcroa)}`);
console.log(`ФИО в сорабском языке если p=0.5: ${countInfBinMist(0.5,FIOcroa)}`);
console.log(`ФИО в сорабском языке если p=1: ${countInfBinMist(0.99999999999,FIOcroa)}`);
