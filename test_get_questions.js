async function test() {
    const url = 'https://itongquiz-api.tongminhkhanh.workers.dev/api';
    const token = '4e23be7934269856066e6a3c2062e33ae4cdcc98ace80ccb054796e119098cab';

    try {
        const response = await fetch(url, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ action: 'get_questions', token })
        });

        if (!response.ok) {
            throw new Error('HTTP error: ' + response.status);
        }
        const data = await response.json();
        console.log('Number of questions directly from D1:', data.length);
        if (data.length > 0) {
            console.log('Sample question:', JSON.stringify(data[0], null, 2));
        } else {
            console.log('Questions data is empty!');
        }
    } catch (err) {
        console.error('Error:', err);
    }
}

test();
